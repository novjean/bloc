import 'dart:convert';

import 'package:bloc/db/entity/tix_tier_item.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/utils/dialog_utils.dart';
import 'package:bloc/utils/number_utils.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';
import 'package:http/http.dart' as http;

import '../../db/entity/party.dart';
import '../../db/entity/party_tix_tier.dart';
import '../../db/entity/tix.dart';
import '../../db/entity/upi_app.dart';
import '../../db/shared_preferences/user_preferences.dart';
import '../../helpers/dummy.dart';
import '../../helpers/fresh.dart';
import '../../main.dart';
import '../../routes/route_constants.dart';
import '../../utils/backup_utils.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';
import '../../widgets/parties/party_banner.dart';
import '../../widgets/payment/upi_app_widget.dart';
import '../../widgets/tix/checkout_tix_tier_item.dart';
import '../../widgets/ui/app_bar_title.dart';
import '../../widgets/ui/dark_button_widget.dart';

class TixCheckoutScreen extends StatefulWidget {
  Tix tix;

  TixCheckoutScreen({key, required this.tix}) : super(key: key);

  @override
  State<TixCheckoutScreen> createState() => _TixCheckoutScreenState();
}

class _TixCheckoutScreenState extends State<TixCheckoutScreen> {
  static const String _TAG = 'TixCheckoutScreen';

  Party mParty = Dummy.getDummyParty(Constants.blocServiceId);
  var _isPartyLoading = true;

  List<TixTier> mTixTiers = [];
  var _isTixTiersLoading = true;

  double igst = 0;
  double subTotal = 0;
  double bookingFee = 0;
  double grandTotal = 0;

  String packageName = "";

  bool testMode = false;

  @override
  void initState() {
    FirestoreHelper.pullParty(widget.tix.partyId).then((res) {
      if (res.docs.isNotEmpty) {
        DocumentSnapshot document = res.docs[0];
        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
        final Party party = Fresh.freshPartyMap(data, false);
        mParty = party;

        setState(() {
          _isPartyLoading = false;
        });
      } else {
        //party not found
        Logx.ist(_TAG, 'party could not be found');
        Navigator.of(context).pop();
      }
    });

    FirestoreHelper.pullTixTiersByTixId(widget.tix.id).then((res) {
      if (res.docs.isNotEmpty) {
        double tixTotal = 0;
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final TixTier tixTier = Fresh.freshTixTierMap(data, false);
          mTixTiers.add(tixTier);

          tixTotal += tixTier.tixTierCount * tixTier.tixTierPrice;
        }

        // igst 15.25%
        // booking fee 5.9%

        igst = tixTotal * Constants.igstPercent;
        subTotal = tixTotal - igst;
        bookingFee = tixTotal * Constants.bookingFeePercent;
        grandTotal = subTotal + igst + bookingFee;

        widget.tix = widget.tix.copyWith(
            igst: igst,
            subTotal: subTotal,
            bookingFee: bookingFee,
            total: grandTotal);
        FirestoreHelper.pushTix(widget.tix);

        setState(() {
          _isTixTiersLoading = false;
        });
      } else {
        Logx.em(_TAG, 'no tix tiers found for tix ${widget.tix.id}');
        Logx.elt(_TAG, 'oops something went wrong, please try again');

        Navigator.of(context).pop();
      }
    });

    super.initState();

    phonePeInit();
  }

  /** phone pe dev **/
  String environment = Constants.testEnvironment;
  String appId = "";
  String merchantId = Constants.testMerchantId;
  String merchantTransactionId =
      DateTime.now().millisecondsSinceEpoch.toString();

  bool enableLogging = true;

  String checksum = "";
  String saltKey = Constants.saltKey;
  String saltIndex = Constants.saltIndex;

  String callbackUrl =
      "https://webhook.site/a7f51d09-7db9-433d-8a6a-45571b725e4b";

  String body = "";
  String apiEndPoint = Constants.phonePeApiEndPoint;

  Object? result;

  void phonePeInit() {
    saltIndex = testMode ? Constants.testSaltIndex : Constants.saltIndex;
    saltKey = testMode ? Constants.testSaltKey : Constants.saltKey;
    environment = testMode ? Constants.testEnvironment : Constants.environment;
    merchantId = testMode ? Constants.testMerchantId : Constants.merchantId;

    if(testMode){
      appId = "";
      if(UserPreferences.myUser.isIos){
        appId = Constants.iosAppId;
      }
    } else {
      if(UserPreferences.myUser.isIos) {
        appId = Constants.iosAppId;
      } else {
        appId = Constants.androidAppId;
      }
    }

    PhonePePaymentSdk.init(environment, appId, merchantId, enableLogging)
        .then((val) {

      // String? sign = await PhonePePaymentSdk.getPackageSignatureForAndroid();
      // Logx.d(_TAG, 'package sign : $sign');

      Logx.d(_TAG, 'phonePe sdk init - $val ');
      result = 'PhonePe SDK initialized - $val';

      widget.tix = widget.tix.copyWith(
        result: 'PhonePe SDK initialized - $val',
      );
      FirestoreHelper.pushTix(widget.tix);

      setState(() {
        result;
      });

      return {};
    }).catchError((error) {

      widget.tix = widget.tix.copyWith(result: 'phone pe init failed: $error');
      FirestoreHelper.pushTix(widget.tix);

      if(UserPreferences.myUser.clearanceLevel>=Constants.ADMIN_LEVEL) {
        DialogUtils.showTextDialog(context, 'phonePeInit: failed. error $error');
      } else {
        Logx.elt(_TAG, 'payment gateway is facing issues, please try again in some time.');
      }

      Navigator.of(context).pop();

      return <dynamic>{};
    });
  }

  getChecksum() {
    int amount = (NumberUtils.roundDouble(grandTotal, 2) * 100).toInt();
    String merchantUserId = UserPreferences.myUser.id;
    String mobileNumber = UserPreferences.myUser.phoneNumber.toString();
    merchantTransactionId = DateTime.now().millisecondsSinceEpoch.toString();

    final requestData = {
        "merchantId": merchantId,
        "merchantTransactionId": merchantTransactionId,
        "merchantUserId": merchantUserId,
        "amount": amount,
        "mobileNumber": mobileNumber,
        "callbackUrl": callbackUrl,
        "paymentInstrument": {
          "type": "PAY_PAGE",
        },
      };

    //String checksum = sha256(base64Body + apiEndPoint + salt) + ### + saltIndex;
    String base64Body = base64.encode(utf8.encode(json.encode(requestData)));
    checksum = '${sha256.convert(utf8.encode(base64Body + apiEndPoint + saltKey)).toString()}###$saltIndex';

    return base64Body;
  }

  void startPgTransaction() async {
    Map<String, String> pgHeaders = {"Content-Type": "application/json"};

    try {
      var response = PhonePePaymentSdk.startPGTransaction(
          body, callbackUrl, checksum, pgHeaders, apiEndPoint, packageName);
      response.then((val) async {
        if (val != null) {
          String status = val['status'].toString();
          String error = val['error'].toString();

          if (status == 'SUCCESS') {
            result = "flow complete. status : success ";

            await checkPhonePePaymentStatus();
          } else {
            result = "flow complete. status : $status and error $error";

            if(UserPreferences.myUser.clearanceLevel>=Constants.ADMIN_LEVEL) {
              DialogUtils.showTextDialog(context, 'startPgTransaction: failed. status $status and error $error');
            } else {
              Logx.elt(_TAG, 'payment was unsuccessful, please try again');
            }

            widget.tix = widget.tix.copyWith(
              result: 'payment was unsuccessful. status $status and error $error',
            );

            FirestoreHelper.pushTix(widget.tix);
          }
        } else {
          result = "flow incomplete";
        }
        result = val;
      }).catchError((error) {
        widget.tix = widget.tix.copyWith(
          result: 'payment was unsuccessful. error : $error',
        );
        FirestoreHelper.pushTix(widget.tix);

        if(UserPreferences.myUser.clearanceLevel>=Constants.ADMIN_LEVEL) {
          DialogUtils.showTextDialog(context, 'startPgTransaction: failed. error $error');
        } else {
          Logx.elt(_TAG, 'payment was unsuccessful, please try again');
        }

        return <dynamic>{};
      });
    } catch (error) {
      if(UserPreferences.myUser.clearanceLevel>=Constants.ADMIN_LEVEL){
        DialogUtils.showTextDialog(context, 'startPgTransaction: failed. error $error');
      } else {
        Logx.elt(_TAG, 'payment was unsuccessful, please try again.');
      }

      widget.tix = widget.tix.copyWith(
        result: 'payment was unsuccessful. error : $error',
      );
      FirestoreHelper.pushTix(widget.tix);
    }
  }

  /** phone pe dev end **/

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: Constants.fontDefault),
      home: Scaffold(
        backgroundColor: Constants.background,
        appBar: AppBar(
          title: AppBarTitle(title: 'checkout'),
          titleSpacing: 0,
          backgroundColor: Constants.background,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: _buildBody(context),
      ),
    );
  }

  _buildBody(BuildContext context) {
    return _isPartyLoading && _isTixTiersLoading
        ? const LoadingWidget()
        : Stack(
            children: [
              ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  PartyBanner(
                    party: mParty,
                    isClickable: false,
                    shouldShowButton: false,
                    isGuestListRequested: false,
                    shouldShowInterestCount: false,
                  ),
                  _showTixTiers(context, mTixTiers),
                  const SizedBox(
                    height:90,
                  ),
                ],
              ),
              // Floating Container at the bottom
              Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _showTixPricePurchase(context)),
            ],
          );
  }

  _showTixPricePurchase(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Divider(),
        Container(
          color: Constants.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                'IGST',
              ),
              Text('\u20B9 ${igst.toStringAsFixed(2)}')
            ],
          ),
        ),
        // const Divider(),
        Container(
          color: Constants.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                'sub-total',
              ),
              Text('\u20B9 ${subTotal.toStringAsFixed(2)}')
            ],
          ),
        ),
        Container(
          color: Constants.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                'booking fee',
              ),
              Text('\u20B9 ${bookingFee.toStringAsFixed(2)}')
            ],
          ),
        ),
        Container(
          color: Constants.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                'grand total',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '\u20B9 ${grandTotal.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),

        const Divider(),
        Container(
          color: Constants.primary,
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              UserPreferences.myUser.clearanceLevel == Constants.ADMIN_LEVEL
                  ? Text('result :\n$result')
                  : const SizedBox(),
              DarkButtonWidget(
                text: 'purchase',
                onClicked: () {
                  body = getChecksum().toString();
                  startPgTransaction();

                  // todo: waiting for PhonePe to fix UPI intent
                  // // here we are gonna check what all is installed on phone
                  // if (!UserPreferences.myUser.isIos) {
                  //   String? apps =
                  //       await PhonePePaymentSdk.getInstalledUpiAppsForAndroid();
                  //
                  //   Iterable l = json.decode(apps!);
                  //   List<UPIApp> upiApps =
                  //       List<UPIApp>.from(l.map((model) => UPIApp.fromJson(model)));
                  //   String appString = '';
                  //
                  //   if(upiApps.isNotEmpty){
                  //     for (var element in upiApps) {
                  //       appString +=
                  //       "${element.applicationName} ${element.version} ${element.packageName}";
                  //     }
                  //
                  //     Logx.d(_TAG, 'installed Upi Apps - $appString');
                  //
                  //     _showUpiAppsBottomSheet(context, upiApps);
                  //   } else {
                  //     startPgTransaction();
                  //   }
                  // } else {
                  //   //ios implement pending
                  //   startPgTransaction();
                  // }
                },
              )
            ],
          ),
        ),
      ],
    );
  }

  checkPhonePePaymentStatus() async {
    try {
      String url = testMode
          ? "https://api-preprod.phonepe.com/apis/pg-sandbox/pg/v1/status/$merchantId/$merchantTransactionId"
          : "https://api.phonepe.com/apis/hermes/pg/v1/status/$merchantId/$merchantTransactionId";

      //SHA256("/pg/v1/status/{merchantId}/{merchantTransactionId}" + saltKey) + "###" + saltIndex
      String concatString =
          "/pg/v1/status/$merchantId/$merchantTransactionId$saltKey";

      var bytes = utf8.encode(concatString);
      var digest = sha256.convert(bytes).toString();
      String xVerify = "$digest###$saltIndex";

      Map<String, String> headers = {
        "Content-Type": "application/json",
        "X-VERIFY": xVerify,
        "X-MERCHANT-ID": merchantId
      };

      try {
        await http.get(Uri.parse(url), headers: headers).then((value) {
          Map<String, dynamic> res = jsonDecode(value.body);

          Logx.d(_TAG, res.toString());

          widget.tix =
              widget.tix.copyWith(merchantTransactionId: merchantTransactionId);

          if (res["success"] &&
              res["code"] == "PAYMENT_SUCCESS" &&
              res['data']['state'] == "COMPLETED") {
            Logx.ilt(_TAG, res["message"]);

            String transactionResult = '';
            try {
              transactionResult = result as String;
            } catch (e) {
              Logx.em(_TAG, e.toString());
            }

            widget.tix = widget.tix.copyWith(
              transactionResponseCode: res['data']['responseCode'],
              transactionId: testMode ? '' : res['data']['transactionId'],
              merchantTransactionId: res['data']['merchantTransactionId'],
              result: transactionResult,
              isSuccess: true,
              isCompleted: true,
            );
            FirestoreHelper.pushTix(widget.tix);
            FirestoreHelper.pushTixBackup(BackupUtils.getTixBackup(widget.tix));

            Logx.ist(_TAG, 'payment was successful, tickets are in box office');

            //update the party tix tier
            FirestoreHelper.pullPartyTixTiers(widget.tix.partyId).then((res) {
              if (res.docs.isNotEmpty) {
                for (int i = 0; i < res.docs.length; i++) {
                  DocumentSnapshot document = res.docs[i];
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;
                  PartyTixTier partyTixTier =
                      Fresh.freshPartyTixTierMap(data, false);

                  for (TixTier tixTier in mTixTiers) {
                    if (tixTier.tixTierName == partyTixTier.tierName) {
                      int soldCount =
                          partyTixTier.soldCount + tixTier.tixTierCount;
                      partyTixTier =
                          partyTixTier.copyWith(soldCount: soldCount);

                      if (soldCount >= partyTixTier.totalTix) {
                        partyTixTier = partyTixTier.copyWith(isSoldOut: true);
                      }
                      FirestoreHelper.pushPartyTixTier(partyTixTier);
                    }
                  }
                }
              }
            });

            //final step
            GoRouter.of(context).pushNamed(RouteConstants.homeRouteName);
            GoRouter.of(context).pushNamed(RouteConstants.boxOfficeRouteName);
          } else {
            Logx.ist(_TAG, "payment was unsuccessful, please try again");

            widget.tix = widget.tix.copyWith(
              result: 'payment was unsuccessful',
            );
            FirestoreHelper.pushTix(widget.tix);
            FirestoreHelper.pushTixBackup(BackupUtils.getTixBackup(widget.tix));
          }
        });
      } on Exception catch (e) {
        Logx.est(_TAG, 'oops, something went wrong. error: $e');

        widget.tix = widget.tix.copyWith(
          result: 'error: $e',
        );
        FirestoreHelper.pushTix(widget.tix);
        FirestoreHelper.pushTixBackup(BackupUtils.getTixBackup(widget.tix));
      }
    } on Exception catch (e) {
      Logx.est(_TAG, 'oops, something went wrong. error: $e');

      widget.tix = widget.tix.copyWith(
        result: 'error: $e',
      );
      FirestoreHelper.pushTix(widget.tix);
      FirestoreHelper.pushTixBackup(BackupUtils.getTixBackup(widget.tix));
    }
  }

  _showTixTiers(BuildContext context, List<TixTier> tixTiers) {
    return SizedBox(
      child: ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: tixTiers.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            TixTier tixTier = tixTiers[index];

            return CheckoutTixTierItem(
              tixTier: tixTier,
            );
          }),
    );
  }

  //todo: keep this here, waiting on PhonePe
  void _showUpiAppsBottomSheet(
      BuildContext context, List<UPIApp> upiApps) {
    showModalBottomSheet(
        backgroundColor: Constants.lightPrimary,
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding:
                EdgeInsets.only(top: mq.height * .03, bottom: mq.height * .03),
            children: [
              const Text('select your payment method',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.w500)),

              //buttons
              Container(
                height: 100,
                padding: const EdgeInsets.only(top: 0),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: upiApps.length,
                  itemBuilder: (context, index) {
                    UPIApp upiApp = upiApps[index];

                    String imageAsset = 'assets/icons/rupee.png';
                    String appName = upiApp.applicationName!;

                    if (appName.toLowerCase().contains('cred')) {
                      imageAsset = 'assets/icons/cred.png';
                    } else if (appName.toLowerCase().contains('gpay')) {
                      imageAsset = 'assets/icons/gpay.jpeg';
                    } else if (appName.toLowerCase().contains('airtel')) {
                      imageAsset = 'assets/icons/airtel.png';
                    } else if (appName.toLowerCase().contains('groww')) {
                      imageAsset = 'assets/icons/groww.png';
                    } else if (appName.toLowerCase().contains('hdfc bank')) {
                      imageAsset = 'assets/icons/hdfc.jpeg';
                    } else if (appName.toLowerCase().contains('amazon')) {
                      imageAsset = 'assets/icons/amazon.jpeg';
                    } else if (appName.toLowerCase().contains('phonepe')) {
                      imageAsset = 'assets/icons/phonepe.png';
                    } else if (appName.toLowerCase().contains('tata neu')) {
                      imageAsset = 'assets/icons/tata_neu.jpeg';
                    } else if (appName.toLowerCase().contains('whatsapp')) {
                      imageAsset = 'assets/icons/whatsapp.jpeg';
                    } else if (appName.toLowerCase().contains('jupiter')) {
                      imageAsset = 'assets/icons/jupiter.png';
                    } else if (appName.toLowerCase().contains('makemytrip')) {
                      imageAsset = 'assets/icons/makemytrip.png';
                    } else if (appName.toLowerCase().contains('bhim')) {
                      imageAsset = 'assets/icons/bhim.png';
                    } else if (appName.toLowerCase().contains('freecharge')) {
                      imageAsset = 'assets/icons/freecharge.png';
                    } else {
                      imageAsset = 'assets/icons/rupee.png';
                    }

                    return GestureDetector(
                        onTap: () {
                          Logx.i(_TAG, '$appName selected for upi transaction');

                          int amount = (NumberUtils.roundDouble(grandTotal, 2) * 100).toInt();
                          String merchantUserId = UserPreferences.myUser.id;
                          String mobileNumber = UserPreferences.myUser.phoneNumber.toString();
                          merchantTransactionId = DateTime.now().millisecondsSinceEpoch.toString();

                          packageName = upiApp.packageName!;

                          final requestData = {
                            "merchantId": merchantId,
                            "merchantTransactionId": merchantTransactionId,
                            "merchantUserId": merchantUserId,
                            "amount": amount,
                            "mobileNumber": mobileNumber,
                            "callbackUrl": callbackUrl,
                            "paymentInstrument": {
                              "type": "UPI_INTENT",
                              "targetApp": upiApp.packageName
                            },
                            "deviceContext": {
                              "deviceOS": "ANDROID"
                            }
                          };

                          String base64Body = base64.encode(utf8.encode(json.encode(requestData)));
                          checksum = '${sha256.convert(utf8.encode(base64Body + apiEndPoint + saltKey)).toString()}###$saltIndex';
                          body = base64Body;

                          startPgTransaction();

                          Navigator.of(context).pop();
                        },
                        child: UpiAppWidget(
                          imageAsset: imageAsset,
                          name: appName,
                        ));
                  },
                ),
              ),
              const Divider(),
              DarkButtonWidget(text: 'more payment modes', height: 50, onClicked: () {
                body = getChecksum().toString();
                startPgTransaction();
              },),
            ],
          );
        });
  }

}
