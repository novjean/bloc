import 'dart:convert';

import 'package:bloc/widgets/ui/button_widget.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';

import '../../widgets/ui/app_bar_title.dart';

class PhonePePayment extends StatefulWidget {
  const PhonePePayment({super.key});

  @override
  State<PhonePePayment> createState() => _PhonePePaymentState();
}

class _PhonePePaymentState extends State<PhonePePayment> {
  String environment = "SANDBOX";
  String appId = "";
  String merchantId = "PGTESTPAYUAT";
  bool enableLogging = true;

  String checksum = "";
  String saltKey = "099eb0cd-02cf-4e2a-8aca-3e6c6aff0399";
  String saltIndex = "1";

  String callbackUrl = "https://webhook.site/a7f51d09-7db9-433d-8a6a-45571b725e4b";

  String body = '';
  String apiEndPoint = "/pg/v1/pay";

  Object? result;

  getChecksum(){
    final requestData = {
      "merchantId": merchantId,
      "merchantTransactionId": "transaction_123",
      "merchantUserId": "90223250",
      "amount": 1000,
      "mobileNumber": "9999999999",
      "callbackUrl": callbackUrl,
      "paymentInstrument": {
        "type": "PAY_PAGE",
      },
    };

    String base64Body = base64.encode(utf8.encode(json.encode(requestData)));

    checksum = '${sha256.convert(utf8.encode(base64Body+apiEndPoint+saltKey)).toString()}###$saltIndex';

    return base64Body;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    phonePeInit();
    body = getChecksum().toString();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: AppBarTitle(title: 'phonePe test'),
          titleSpacing: 0,
        ), body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ButtonWidget(text: 'start transaction', onClicked: () {
            startPgTransaction();
          }),
          const SizedBox(height: 20),
          Text('Result \n $result'),
        ],
      ),
      ),
    );
  }

  void phonePeInit() {
    PhonePePaymentSdk.init(environment, appId, merchantId, enableLogging)
        .then((val) => {
      setState(() {
        result = 'PhonePe SDK Initialized - $val';
      })
    }).catchError((error) {
      handleError(error);
      return <dynamic>{};
    });
  }

  void startPgTransaction() async {
    String packageName = "";

    try {
      var response = PhonePePaymentSdk.startTransaction(
          body, callbackUrl, checksum, packageName);
      response
          .then((val) => {
        setState(() {
          if(val!=null){
            String status = val['status'].toString();
            String error = val['error'].toString();

            if(status == 'SUCCESS'){
              result = "Flow complete - status : SUCCESS ";
            } else {
              result = "Flow complete - status : $status and error $error ";
            }

          } else {
            result = "Flow Incomplete";
          }

          result = val;
        })
      })
          .catchError((error) {
        handleError(error);
        return <dynamic>{};
      });
    } catch (error) {
      handleError(error);
    }
  }

  void handleError(error) {
    setState(() {
      result = {"error" : error};
    });
  }
}
