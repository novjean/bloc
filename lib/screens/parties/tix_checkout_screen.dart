import 'dart:convert';

import 'package:bloc/db/entity/tix_tier_item.dart';
import 'package:bloc/helpers/firestore_helper.dart';
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

  bool isTestMode = true;

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
        //party not found.
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
        Logx.em(_TAG, 'no tix tiers found for ${widget.tix.partyId}');
      }
    });

    super.initState();

    phonePeInit();
    body = getChecksum().toString();
  }

  /** phone pe dev **/
  String environment = Constants.testEnvironment;
  String appId = "";
  String merchantId = Constants.testmerchantId;
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
    environment = isTestMode ? Constants.testEnvironment : Constants.environment;
    appId = isTestMode ? "" : Constants.appId;
    merchantId = isTestMode ? Constants.testmerchantId : Constants.merchantId;

    PhonePePaymentSdk.init(environment, appId, merchantId, enableLogging)
        .then((val) => {
              setState(() {
                Logx.d(_TAG, 'phonePe sdk init - $val ');
                result = 'PhonePe SDK initialized - $val';

                widget.tix = widget.tix.copyWith(
                  result: 'PhonePe SDK initialized - $val',
                );
                FirestoreHelper.pushTix(widget.tix);
              })
            })
        .catchError((error) {
      handleError(error);
      return <dynamic>{};
    });
  }

  getChecksum() {
    int amount = grandTotal.toInt() * 100;
    String merchantUserId = UserPreferences.myUser.id;
    String mobileNumber = UserPreferences.myUser.phoneNumber.toString();

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

    String base64Body = base64.encode(utf8.encode(json.encode(requestData)));

    checksum =
        '${sha256.convert(utf8.encode(base64Body + apiEndPoint + saltKey)).toString()}###$saltIndex';

    return base64Body;
  }

  void startPgTransaction() async {
    Map<String, String> pgHeaders = {};
    String packageName = "";

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

            Logx.elt(_TAG, 'payment was unsuccessful. status $status and error $error');

            // _showPaymentErrorDialog(context, status, error);
          }
        } else {
          result = "flow incomplete";
        }
        result = val;
      }).catchError((error) {
        handleError(error);

        widget.tix = widget.tix.copyWith(
          result: 'payment was unsuccessful. error : $error',
        );
        FirestoreHelper.pushTix(widget.tix);
        FirestoreHelper.pushTixBackup(BackupUtils.getTixBackup(widget.tix));

        return <dynamic>{};
      });
    } catch (error) {
      Logx.elt(_TAG, 'payment was unsuccessful, please try again.');

      handleError(error);

      widget.tix = widget.tix.copyWith(
        result: 'payment was unsuccessful. error : $error',
      );
      FirestoreHelper.pushTix(widget.tix);
      FirestoreHelper.pushTixBackup(BackupUtils.getTixBackup(widget.tix));
    }
  }

  void handleError(error) {
    setState(() {
      result = {"error": error};
    });
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
                  const SizedBox(height: 20),
                  const SizedBox(
                    height: 70,
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
              UserPreferences.myUser.clearanceLevel > Constants.ADMIN_LEVEL
                  ? Text('result :\n$result')
                  : const SizedBox(),
              DarkButtonWidget(
                text: 'purchase',
                onClicked: () {
                  body = getChecksum().toString();

                  startPgTransaction();

                  // here we are gonna check what all is installed on phone
                  // bool isIos = Theme.of(context).platform == TargetPlatform.iOS;
                  // if (!isIos) {
                  //   String? apps =
                  //       await PhonePePaymentSdk.getInstalledUpiAppsForAndroid();
                  //
                  //   Iterable l = json.decode(apps!);
                  //   List<UPIApp> upiApps =
                  //       List<UPIApp>.from(l.map((model) => UPIApp.fromJson(model)));
                  //   String appString = '';
                  //   for (var element in upiApps) {
                  //     appString +=
                  //         "${element.applicationName} ${element.version} ${element.packageName}";
                  //   }
                  //
                  //   Logx.d(_TAG, 'installed Upi Apps - $appString');
                  //
                  //   _showUpiAppsBottomSheet(context, upiApps, price);
                  // } else {
                  //   //ios implement pending
                  // }

                  // Logx.ist(_TAG, 'tickets purchased, navigating to home.');
                  // GoRouter.of(context).goNamed(RouteConstants.landingRouteName);
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
      String prodUrl =
          "https://api.phonepe.com/apis/hermes/pg/v1/status/$merchantId/$merchantTransactionId";
      String url =
          "https://api-preprod.phonepe.com/apis/pg-sandbox/pg/v1/status/$merchantId/$merchantTransactionId";

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
              merchantTransactionId: res['data']['merchantTransactionId'],
              transactionResponseCode: res['data']['responseCode'],
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

  void _showUpiAppsBottomSheet(
      BuildContext context, List<UPIApp> upiApps, double amount) {
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
                EdgeInsets.only(top: mq.height * .03, bottom: mq.height * .05),
            children: [
              //pick profile picture label
              const Text('select your payment app',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.w500)),

              //for adding some space
              SizedBox(height: mq.height * .02),

              //buttons
              Container(
                height: 100, // Set the desired height
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: upiApps.length,
                  itemBuilder: (context, index) {
                    UPIApp upiApp = upiApps[index];

                    String imageAsset = 'assets/icons/upipayment.png';
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
                    } else {
                      imageAsset = 'assets/icons/upipayment.png';
                    }

                    return GestureDetector(
                        onTap: () {
                          Logx.ist(_TAG, '$appName selected');
                        },
                        child: UpiAppWidget(
                          imageAsset: imageAsset,
                          name: appName,
                        ));
                  },
                ),
              ),
            ],
          );
        });
  }

  void _showPaymentErrorDialog(
      BuildContext context, String status, String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Constants.lightPrimary,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          contentPadding: const EdgeInsets.all(16.0),
          title: const Text(
            '🙆 payment was not successful',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, color: Colors.black),
          ),
          content: Text('status: $status \n\nerror: $error'),
          actions: [
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Constants.darkPrimary), // Set your desired background color
              ),
              child: const Text("close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }
}
