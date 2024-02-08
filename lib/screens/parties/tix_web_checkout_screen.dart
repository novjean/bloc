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

        // PhonePeApiService.startTransaction(widget.tix).then((res) {
        //   setState(() {
        //     transactUrl = res;
        //     _isTransactUrlLoading = false;
        //   });
        // });

        PhonePeApiService.startTestTransaction(widget.tix).then((res) {
          setState(() {
            transactUrl = res;
            _isTransactUrlLoading = false;
          });
        });

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
                // onCloseWindow:  (InAppWebViewController controller) {
                //   controller.evaluateJavascript(source: "document.documentElement.innerHTML")
                //       .then((value) async {
                //         Logx.d(_TAG, 'script : $value');
                //
                //     // if(value.contains("name=\"paymentId\"")) {
                //     //
                //     // }
                //   });
                // },
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