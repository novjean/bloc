import 'dart:async';
import 'dart:convert';

import 'package:bloc/services/phone_pe_api_service.dart';
import 'package:bloc/widgets/ui/app_bar_title.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';

import '../../db/entity/party.dart';
import '../../db/entity/tix.dart';
import '../../db/entity/tix_tier_item.dart';
import '../../db/shared_preferences/user_preferences.dart';
import '../../helpers/api_helper.dart';
import '../../helpers/firestore_helper.dart';
import '../../helpers/fresh.dart';
import '../../routes/route_constants.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';
import '../../utils/number_utils.dart';

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

  String responseUrl = '';
  var _isResponseUrlLoading = true;

  var _isPaymentFailed = false;

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
            merchantTransactionId : DateTime.now().millisecondsSinceEpoch.toString(),
            igst: igst,
            subTotal: subTotal,
            bookingFee: bookingFee,
            total: grandTotal);
        FirestoreHelper.pushTix(widget.tix);

        _showApiInfoDialog(context);

        // PhonePeApiService.startTransaction(widget.tix, context).then((res) {
        //   setState(() {
        //     transactUrl = res;
        //
        //     if(transactUrl.isNotEmpty){
        //       _isTransactUrlLoading = false;
        //     }
        //   });
        //
        //   startPaymentStatusListener();
        // });

        // PhonePeApiService.startTestTransaction(widget.tix).then((res) {
        //   setState(() {
        //     transactUrl = res;
        //     _isTransactUrlLoading = false;
        //   });
        //
        //   startPaymentStatusListener();
        // });

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

    super.initState();

  }

  _showApiInfoDialog(BuildContext context){
    final Map<String, dynamic> requestData = {
      "merchantId": Constants.merchantId,
      "merchantTransactionId": widget.tix.merchantTransactionId,
      "merchantUserId": UserPreferences.myUser.id,
      "amount": (NumberUtils.roundDouble(widget.tix.total, 2) * 100).toInt(),
      "redirectUrl": "http://bloc.bar",
      "redirectMode": "REDIRECT",
      "callbackUrl": "https://webhook.site/5c3f7757-89a5-4c06-8eae-c92e898a852c",
      "mobileNumber": '${UserPreferences.myUser.phoneNumber}',
      "paymentInstrument": {
        "type": "PAY_PAGE"
      },
    };

    String request = ApiHelper.encodeJsonToBase64(requestData);
    String saltKey = Constants.saltKey;
    String saltIndex = Constants.saltIndex;
    //String checksum = sha256(base64Body + apiEndPoint + salt) + ### + saltIndex;
    String checksum = '${sha256.convert(utf8.encode(request
        + Constants.phonePeApiEndPoint + saltKey))}###$saltIndex';

    startPaymentStatusListener();


    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Constants.lightPrimary,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(19.0))),
          contentPadding: const EdgeInsets.all(16.0),
          title: const Text(
            'transaction api info',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, color: Colors.black),
          ),
          content: Text(
              'request: $request \n\nchecksum: $checksum'),
          actions: [
            TextButton(child: Text('copy checksum'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: checksum));
              Logx.ist(_TAG, 'checksum copied to clipboard');
            },
            ),
            TextButton(child: Text('copy request'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: request));
                Logx.ist(_TAG, 'request copied to clipboard');
              },
            ),
            TextButton(
              child: const Text("continue"),
              onPressed: () async {
                PhonePeApiService.startTransaction2(context, request, checksum).then((res) {
                  setState(() {
                    transactUrl = res;

                    if(transactUrl.isNotEmpty){
                      _isTransactUrlLoading = false;
                    }
                  });

                });
              },
            ),
          ],
        );
      },
    );
  }

  void startPaymentStatusListener() {
    const Duration checkInterval = Duration(seconds: 5); // Set your desired interval

    Timer.periodic(checkInterval, (Timer timer) {
      PhonePeApiService.checkStatus(widget.tix).then((res) {
        setState(() {
          bool isCompleted = res;

          if(isCompleted){
            timer.cancel();

            FirestoreHelper.pullTix(widget.tix.id).then((res) {
              if(res.docs.isNotEmpty){
                DocumentSnapshot document = res.docs[0];
                Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                widget.tix = Fresh.freshTixMap(data, false);

                if(widget.tix.isCompleted){
                  if(widget.tix.isSuccess){
                    GoRouter.of(context).pushNamed(RouteConstants.landingRouteName);
                    GoRouter.of(context).pushNamed(RouteConstants.boxOfficeRouteName);
                  } else {
                    setState(() {
                      _isPaymentFailed = true;
                    });
                  }
                }
              }
            });
          }
        });
      });
      // You can stop the timer when the payment is complete or implement other conditions
    });
  }

  @override
  Widget build(BuildContext context) {

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
            backgroundColor: Constants.background,
            title: AppBarTitle(title: 'payment'),
            titleSpacing: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, color: Constants.lightPrimary,),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
          ),
          body: 
          // Expanded(child: Container(child:
          //   _isPaymentFailed ? Center(child: Text('payment failed!'),): LoadingWidget(),) ,)
          
          _isPaymentFailed ? Expanded(
            child: Center(
              child: Text('payment failed!'),),
          ):
          
          Stack(
            children: [
              _isTransactUrlLoading ? const LoadingWidget() : InAppWebView(
                initialUrlRequest: URLRequest(
                    url: WebUri(transactUrl),
                  // headers: headers,
                ),
                onWebViewCreated: (InAppWebViewController controller) {
                  inAppWebViewController = controller;
                  // PhonePeApiService.checkStatus()
                },
                onProgressChanged: (InAppWebViewController controller, int progress) {
                  setState(() {
                    _progress = progress/100;
                  });
                },
              ),
              _progress < 1 ? LinearProgressIndicator(
                value: _progress,
              ) : const SizedBox()
            ],
          )
        ),
      ),
    );
  }


}