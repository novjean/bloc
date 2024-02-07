
import 'package:bloc/services/phone_pe_api_service.dart';
import 'package:bloc/widgets/ui/app_bar_title.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../db/entity/party.dart';
import '../../db/entity/tix.dart';
import '../../db/entity/tix_tier_item.dart';
import '../../helpers/firestore_helper.dart';
import '../../helpers/fresh.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';

class TixWebCheckoutScreen extends StatefulWidget {
  Tix tix;
  Party party;

  TixWebCheckoutScreen({required this.tix, required this.party});

  @override
  _TixWebCheckoutScreenState createState() => _TixWebCheckoutScreenState();
}

class _TixWebCheckoutScreenState extends State<TixWebCheckoutScreen> {
  static const String _TAG = 'TixWebCheckoutScreen';

  String url = 'https://www.google.com';

  double _progress = 0;
  late InAppWebViewController inAppWebViewController;

  List<TixTier> mTixTiers = [];
  var _isTixTiersLoading = true;

  double igst = 0;
  double subTotal = 0;
  double bookingFee = 0;
  double grandTotal = 0;

  String transactUrl = '';
  var _isTransactUrlLoading = true;

  @override
  void initState() {
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

        igst = tixTotal * Constants.igstPercent;
        subTotal = tixTotal - igst;
        bookingFee = tixTotal * widget.party.bookingFeePercent;
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

        widget.tix = widget.tix.copyWith(result: 'checkout screen failed: no tix tiers found for tix ${widget.tix.id}');
        FirestoreHelper.pushTix(widget.tix);

        Navigator.of(context).pop();
      }
    });

    PhonePeApiService.startTransaction().then((res) {
      setState(() {
        transactUrl = res;
        _isTransactUrlLoading = false;
      });
    });

    super.initState();

    phonePeInit();
  }

  String merchantId = Constants.testMerchantId;
  String merchantTransactionId = DateTime.now().millisecondsSinceEpoch.toString();

  bool enableLogging = true;

  String checksum = "";
  String saltKey = Constants.saltKey;
  String saltIndex = Constants.saltIndex;

  String callbackUrl =
      "https://webhook.site/a7f51d09-7db9-433d-8a6a-45571b725e4b";
  String redirectUrl =
      "https://www.bloc.bar";

  String body = "";
  String apiEndPoint = Constants.phonePeApiEndPoint;

  Object? result;

  bool testMode = false;

  void phonePeInit() {
    saltIndex = testMode ? Constants.testSaltIndex : Constants.saltIndex;
    saltKey = testMode ? Constants.testSaltKey : Constants.saltKey;
    merchantId = testMode ? Constants.testMerchantId : Constants.merchantId;
  }

  // getChecksum(){
  //   int amount = (NumberUtils.roundDouble(grandTotal, 2) * 100).toInt();
  //   String merchantUserId = UserPreferences.myUser.id;
  //   String mobileNumber = UserPreferences.myUser.phoneNumber.toString();
  //   merchantTransactionId = DateTime.now().millisecondsSinceEpoch.toString();
  //
  //   final requestData = {
  //     "merchantId": merchantId,
  //     "merchantTransactionId": merchantTransactionId,
  //     "merchantUserId": merchantUserId,
  //     "amount": amount,
  //     "redirectUrl": redirectUrl,
  //     "redirectMode": "REDIRECT",
  //     "callbackUrl": callbackUrl,
  //     "mobileNumber": mobileNumber,
  //     "paymentInstrument": {
  //       "type": "PAY_PAGE",
  //     },
  //   };
  //
  //   //String checksum = sha256(base64Body + apiEndPoint + salt) + ### + saltIndex;
  //   String base64Body = base64.encode(utf8.encode(json.encode(requestData)));
  //   checksum = '${sha256.convert(utf8.encode(base64Body + apiEndPoint + saltKey)).toString()}###$saltIndex';
  //
  //   return base64Body;
  // }

  @override
  Widget build(BuildContext context) {
    // var url = "https://api-preprod.phonepe.com/apis";

    // WebUri uri = WebUri();
    // Map<String, String> headers = {
    //   'Content-Type': 'application/json',
    //   'X-VERIFY': getChecksum(),
    // };

    return PopScope(
      canPop: true,
      // onPopInvoked: (b) async {
      //   bool isLastPage = await inAppWebViewController.canGoBack();
      //
      //   if(isLastPage){
      //     inAppWebViewController.goBack();
      //     return;
      //   }
      // },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: AppBarTitle(title: 'payment'),
          ),
          body: Stack(
            children: [
              _isTransactUrlLoading ?
              const LoadingWidget() :
              InAppWebView(
                initialUrlRequest: URLRequest(
                    url: WebUri(transactUrl),
                  // headers: headers,
                ),
                onWebViewCreated: (InAppWebViewController controller) {
                  inAppWebViewController = controller;
                },
                onProgressChanged: (InAppWebViewController controller, int progress) {
                  setState(() {
                    _progress = progress/100;
                  });
                },
              ),
              _progress < 1 ? Container (
                child: LinearProgressIndicator(
                  value: _progress,
                ),
              ) : const SizedBox()
            ],
          )
        ),
      ),
    );
  }
}