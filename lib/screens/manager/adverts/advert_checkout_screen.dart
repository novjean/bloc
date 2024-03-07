import 'dart:convert';

import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/main.dart';
import 'package:bloc/utils/number_utils.dart';
import 'package:bloc/utils/string_utils.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';
import 'package:http/http.dart' as http;

import '../../../db/entity/advert.dart';
import '../../../db/shared_preferences/user_preferences.dart';
import '../../../routes/route_constants.dart';
import '../../../utils/constants.dart';
import '../../../utils/dialog_utils.dart';
import '../../../utils/logx.dart';
import '../../../widgets/ui/app_bar_title.dart';

class AdvertCheckoutScreen extends StatefulWidget {
  Advert advert;

  AdvertCheckoutScreen({key, required this.advert}) : super(key: key);

  @override
  State<AdvertCheckoutScreen> createState() => _AdvertCheckoutScreenState();
}

class _AdvertCheckoutScreenState extends State<AdvertCheckoutScreen> {
  static const String _TAG = 'AdvertCheckoutScreen';

  double igst = 0;
  double subTotal = 0;
  double bookingFee = 0;
  double grandTotal = 0;

  String packageName = "";

  bool testMode = false;

  @override
  void initState() {
    Logx.d(_TAG, 'advert user name: ${widget.advert.userName}');

    igst = widget.advert.igst;
    subTotal = widget.advert.subTotal;
    bookingFee = widget.advert.bookingFee;
    grandTotal = widget.advert.total;

    super.initState();

    if(!kIsWeb){
      phonePeInit();
    }
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

      setState(() {
        result = 'PhonePe SDK initialized - $val';

        widget.advert = widget.advert.copyWith(
          result: 'PhonePe SDK initialized - $val',
        );
        FirestoreHelper.pushAdvert(widget.advert);
      });
      return {};
    }).catchError((error) {
      if(UserPreferences.myUser.clearanceLevel>=Constants.ADMIN_LEVEL) {
        Logx.em(_TAG, 'PhonePe initialization failed. error: $error');
        _showTransactionFailedDialog(context, 'PhonePe initialization failed', 'error: $error');
      } else {
        Logx.em(_TAG, 'PhonePe transaction failed. error: $error');
        _showTransactionFailedDialog(context, 'PhonePe transaction failed', 'Unfortunately, the payment was unsuccessful. Please try again.');
      }

      widget.advert = widget.advert.copyWith(
        result: 'PhonePe initialization failed. error: $error',
      );
      FirestoreHelper.pushAdvert(widget.advert);
      //todo: long term remove tix but keeping this to know if init fails

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

  void _startTransaction() async {
    //check if values are all good
    if(!isAdvertValid()){
      Logx.est(_TAG, 'something went wrong, please try again!');
      Navigator.of(context).pop();
      return;
    }

    try {
      var response = PhonePePaymentSdk.startTransaction(
          body, callbackUrl, checksum, packageName);
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
              Logx.em(_TAG, 'PhonePe transaction failed. \nstatus: $status\nerror: $error');
              _showTransactionFailedDialog(context, 'PhonePe transaction failed', 'status: $status\nerror: $error');
            } else {
              Logx.em(_TAG, 'PhonePe transaction failed. \nstatus: $status\nerror: $error');
              _showTransactionFailedDialog(context, 'PhonePe transaction failed', 'Unfortunately, the payment was unsuccessful. Please try again.');
            }

            widget.advert = widget.advert.copyWith(
              result: 'PhonePe transaction failed. \nstatus: $status\nerror: $error',
            );
            FirestoreHelper.pushAdvert(widget.advert);
          }
        } else {
          result = "flow incomplete";
        }
        result = val;
      }).catchError((error) {
        if(UserPreferences.myUser.clearanceLevel>=Constants.ADMIN_LEVEL) {
          Logx.em(_TAG, 'PhonePe transaction failed. error: $error');
          _showTransactionFailedDialog(context, 'PhonePe transaction failed', 'error: $error');
        } else {
          Logx.em(_TAG, 'PhonePe transaction failed. error: $error');
          _showTransactionFailedDialog(context, 'PhonePe transaction failed', 'Unfortunately, the payment was unsuccessful. Please try again.');
        }

        widget.advert = widget.advert.copyWith(
          result: 'PhonePe transaction failed. error: $error',
        );
        FirestoreHelper.pushAdvert(widget.advert);

        return <dynamic>{};
      });
    } catch (error) {
      if(UserPreferences.myUser.clearanceLevel>=Constants.ADMIN_LEVEL){
        Logx.em(_TAG, 'PhonePe transaction failed. error: $error');
        _showTransactionFailedDialog(context, 'PhonePe transaction failed', 'error: $error');
      } else {
        Logx.em(_TAG, 'PhonePe transaction failed. error: $error');
        _showTransactionFailedDialog(context, 'PhonePe transaction failed', 'Unfortunately, the payment was unsuccessful. Please try again.');
      }

      widget.advert = widget.advert.copyWith(
        result: 'payment was unsuccessful. error : $error',
      );
      FirestoreHelper.pushAdvert(widget.advert);
    }
  }

  _showTransactionFailedDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Constants.lightPrimary,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          contentPadding: const EdgeInsets.all(16.0),
          title: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, color: Constants.darkPrimary),
          ),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text("close", style: TextStyle(color: Constants.darkPrimary),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Constants.darkPrimary),
              ),
              child: const Text("߷ retry", style: TextStyle(color: Constants.primary),),
              onPressed: () {
                _startTransaction();

                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  /** phone pe dev end **/

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: Constants.fontDefault),
      home: PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: Constants.background,
          appBar: AppBar(
            title: AppBarTitle(title: 'checkout'),
            titleSpacing: 0,
            backgroundColor: Constants.background,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, color: Constants.lightPrimary),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          body: _buildBody(context),
        ),
      ),
    );
  }

  _buildBody(BuildContext context) {
    return Stack(
      children: [
        ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            // PartyBanner(
            //   party: widget.party,
            //   isClickable: false,
            //   shouldShowButton: false,
            //   isGuestListRequested: false,
            //   shouldShowInterestCount: false,
            // ),
            // _displayTixTiers(context, mTixTiers),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Hero(
                  tag: widget.advert.id,
                  child: Card(
                    elevation: 1,
                    color: Constants.lightPrimary,
                    shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2.0, left: 5, right: 5),
                      child: ListTile(
                        leading: FadeInImage(
                          placeholder: const AssetImage(
                              'assets/icons/logo.png'),
                          image: NetworkImage(widget.advert.imageUrls[0]),
                          fit: BoxFit.cover,),
                        title: RichText(
                          text: TextSpan(
                            text: widget.advert.title,
                            style: const TextStyle(
                                fontFamily: Constants.fontDefault,
                                color: Colors.black,
                                overflow: TextOverflow.ellipsis,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        subtitle: RichText(
                          maxLines: 1,
                          text: TextSpan(
                              text:
                              'ad @ ${StringUtils.rs}10.00 /day',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontFamily: Constants.fontDefault,
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal),
                              children: <TextSpan>[
                                TextSpan(text: '',
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontFamily:
                                        Constants.fontDefault,
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal)),
                              ]),
                        ),
                        trailing: Text('${StringUtils.rs} ${widget.advert.total.toStringAsFixed(2)}', style: TextStyle(
                          color: Colors.black,
                          fontFamily:
                          Constants.fontDefault,
                          fontSize: 14,
                        ),),
                      ),
                    ),
                  ),
                ),
              ),
            ),
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
                'service fee',
              ),
              Text('${StringUtils.rs} ${bookingFee.toStringAsFixed(2)}')
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

        Container(
          color: Constants.primary,
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              UserPreferences.myUser.clearanceLevel == Constants.ADMIN_LEVEL
                  ? Text('result :\n$result')
                  : const SizedBox(),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.background,
                  foregroundColor: Constants.primary,
                  shadowColor: Colors.white30,
                  elevation: 3,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(9),)
                    ,
                  ),
                ),
                onPressed: () {
                  if(!kIsWeb){
                    body = getChecksum().toString();
                    _startTransaction();
                  } else {
                    Logx.ilt(_TAG, 'payment is via the app only');

                    DialogUtils.showDownloadAppDialog(context, DialogUtils.downloadDefault);
                  }
                  },
                label: const Text(
                  'purchase',
                  style: TextStyle(fontSize: 20, color: Constants.primary),
                ),
                icon: const Icon(
                  Icons.local_play,
                  size: 24.0,
                ),
              ),
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

          widget.advert =
              widget.advert.copyWith(merchantTransactionId: merchantTransactionId);

          if (res["success"] &&
              res["code"] == "PAYMENT_SUCCESS" &&
              res['data']['state'] == "COMPLETED") {
            Logx.ilt(_TAG, res["message"]);

            String transactionResult = '';
            try {
              transactionResult = result as String;
            } catch (e) {
              Logx.em(_TAG, e.toString());
              transactionResult = 'result as string failed.\nerror: $e';
            }

            widget.advert = widget.advert.copyWith(
              transactionResponseCode: res['data']['responseCode'],
              transactionId: testMode ? '' : res['data']['transactionId'],
              merchantTransactionId: res['data']['merchantTransactionId'],
              result: 'transaction result: $transactionResult',
              isSuccess: true,
              isCompleted: true,
            );
            FirestoreHelper.pushAdvert(widget.advert);
            // FirestoreHelper.pushTixBackup(BackupUtils.getTixBackup(widget.advert));

            Logx.ist(_TAG, 'payment was successful. tickets are in box office.');

            //final step
            GoRouter.of(context).pushNamed(RouteConstants.landingRouteName);
            GoRouter.of(context).pushNamed(RouteConstants.advertiseRouteName);
          } else {
            Logx.ist(_TAG, "payment was unsuccessful, please try again.");

            String transactionResult = '';
            try {
              transactionResult = result as String;
            } catch (e) {
              Logx.em(_TAG, e.toString());
              transactionResult = 'result as string failed.\nerror: $e';
            }

            widget.advert = widget.advert.copyWith(
              result: 'payment was unsuccessful.\ntransaction result: $transactionResult',
            );
            FirestoreHelper.pushAdvert(widget.advert);
            // FirestoreHelper.pushTixBackup(BackupUtils.getTixBackup(widget.advert));
          }
        });
      } on Exception catch (e) {
        Logx.est(_TAG, 'oops, something went wrong. error: $e');

        widget.advert = widget.advert.copyWith(
          result: 'error: $e',
        );
        FirestoreHelper.pushAdvert(widget.advert);
        // FirestoreHelper.pushTixBackup(BackupUtils.getTixBackup(widget.advert));
      }
    } on Exception catch (e) {
      Logx.est(_TAG, 'oops, something went wrong. error: $e');

      widget.advert = widget.advert.copyWith(
        result: 'PhonePe check payment error: $e',
      );
      FirestoreHelper.pushAdvert(widget.advert);
      // FirestoreHelper.pushTixBackup(BackupUtils.getTixBackup(widget.advert));
    }
  }

  bool isAdvertValid() {
    if(UserPreferences.isUserLoggedIn()){
      if(widget.advert.userId != UserPreferences.myUser.id){
        Logx.em(_TAG, 'purchase not initiating as user id is not matching');
        return false;
      }
      if(widget.advert.userPhone != UserPreferences.myUser.phoneNumber.toString()){
        Logx.em(_TAG, 'advert purchase not initiating as user phone not matching');
        return false;
      }
      if(widget.advert.imageUrls.isEmpty){
        Logx.em(_TAG, 'advert purchase not initiating as no images found');
        return false;
      }
      return true;
    } else {
      Logx.em(_TAG, 'user is not logged in, cannot purchase ticket!');
      return false;
    }
  }
}
