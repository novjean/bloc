import 'dart:convert';
import 'package:bloc/db/ext_entity/phone_pe_api_response_data.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../db/entity/tix.dart';
import '../db/shared_preferences/user_preferences.dart';
import '../helpers/api_helper.dart';
import '../utils/constants.dart';
import '../utils/logx.dart';
import '../utils/number_utils.dart';

class PhonePeApiService {
  static const String _TAG = 'PhonePeApiService';

  static String callbackUrl =
      "https://webhook.site/a7f51d09-7db9-433d-8a6a-45571b725e4b";
  static String redirectUrl = "https://www.google.com";

  static getChecksum(String request){
    String saltKey = Constants.saltKey;
    String saltIndex = Constants.saltIndex;

    //String checksum = sha256(base64Body + apiEndPoint + salt) + ### + saltIndex;
    String checksum = '${sha256.convert(utf8.encode(request
        + Constants.phonePeApiEndPoint + saltKey))}###$saltIndex';
    return checksum;
  }

  static startTransaction2(BuildContext context, String request, String checksum) async {
    Logx.i(_TAG, 'phone pe web start real transaction');

    String saltKey = Constants.saltKey;
    String saltIndex = Constants.saltIndex;
    //String checksum = sha256(base64Body + apiEndPoint + salt) + ### + saltIndex;
    String checksum = '${sha256.convert(utf8.encode(request
        + Constants.phonePeApiEndPoint + saltKey))}###$saltIndex';
    Logx.d(_TAG, 'checksum: $checksum');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'X-VERIFY': checksum,
    };

    try{
      Dio dio = Dio();

      Response res = await dio.post(Constants.apiProdHostUrl,
          options: Options(headers: headers),
          data: {
            "request": request
          });

      if (res.statusCode == 200) {
        Logx.i(_TAG, 'response code 200 success');

        PhonePeApiResponseData data = PhonePeApiResponseData.fromJson(res.data['data']);
        String transactUrl = data.instrumentResponse!.redirectInfo!.url!;
        Logx.i(_TAG, 'transact url : $transactUrl');

        // final uri = Uri.parse(transactUrl);
        // NetworkUtils.launchInAppBrowser(uri);

        return transactUrl;
      } else {
        Logx.elt(_TAG, 'failed with response : ${res.statusCode} : ${res.toString()}');

        return '';
      }
    } catch (e){
      Logx.em(_TAG, 'error : ${e.toString()}');
      await _showErrorDialog(context, e.toString());

      return '';
    }
  }


  static startTransaction(Tix tix, BuildContext context) async {
    Logx.i(_TAG, 'phone pe web start real transaction');

    final Map<String, dynamic> requestData = {
      "merchantId": Constants.merchantId,
      "merchantTransactionId": tix.merchantTransactionId,
      "merchantUserId": UserPreferences.myUser.id,
      "amount": (NumberUtils.roundDouble(tix.total, 2) * 100).toInt(),
      "redirectUrl": "http://bloc.bar",
      "redirectMode": "REDIRECT",
      "callbackUrl": "https://webhook.site/5c3f7757-89a5-4c06-8eae-c92e898a852c",
      "mobileNumber": '${UserPreferences.myUser.phoneNumber}',
      "paymentInstrument": {
        "type": "PAY_PAGE",
      },
    };

    String request = ApiHelper.encodeJsonToBase64(requestData);
    Logx.i(_TAG, 'request: $request');

    String saltKey = Constants.saltKey;
    String saltIndex = Constants.saltIndex;
    //String checksum = sha256(base64Body + apiEndPoint + salt) + ### + saltIndex;
    String checksum = '${sha256.convert(utf8.encode(request
        + Constants.phonePeApiEndPoint + saltKey))}###$saltIndex';
    Logx.d(_TAG, 'checksum: $checksum');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'X-VERIFY': checksum,
    };

    try{
      Dio dio = Dio();

      Response res = await dio.post(Constants.apiProdHostUrl,
          options: Options(headers: headers),
          data: {
            "request": request
          });

      if (res.statusCode == 200) {
        Logx.i(_TAG, 'response code 200 success');

        PhonePeApiResponseData data = PhonePeApiResponseData.fromJson(res.data['data']);
        String transactUrl = data.instrumentResponse!.redirectInfo!.url!;
        Logx.i(_TAG, 'transact url : $transactUrl');

        // final uri = Uri.parse(transactUrl);
        // NetworkUtils.launchInAppBrowser(uri);

        return transactUrl;
      } else {
        Logx.elt(_TAG, 'failed with response : ${res.statusCode} : ${res.toString()}');

        return '';
      }
    } catch (e){
      Logx.em(_TAG, 'error : ${e.toString()}');
      await _showErrorDialog(context, e.toString());

      return '';
    }
  }

  static checkStatus(Tix tix) async {
    String merchantTransactionId = tix.merchantTransactionId;
    String saltKey = Constants.saltKey;
    String saltIndex = Constants.saltIndex;

    String check = '/pg/v1/status/${Constants.merchantId}/$merchantTransactionId$saltKey';
    String checksum = '${sha256.convert(utf8.encode(check))}###$saltIndex';
    Logx.d(_TAG, 'checkStatus checksum: $checksum');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'X-VERIFY': checksum,
      'X-MERCHANT-ID': Constants.merchantId,
    };

    try{
      Dio dio = Dio();

      String checkStatusUrl = '${Constants.checkStatusUrl}/${Constants.merchantId}/$merchantTransactionId';

      Response res = await dio.get(checkStatusUrl,
          options: Options(headers: headers),
          data: {});

      if (res.statusCode == 200) {
        Logx.i(_TAG, 'response code 200 success');

        String code = res.data['code'];

        if(code == 'PAYMENT_SUCCESS'){
          Logx.i(_TAG, 'payment is success');

          Map<String, dynamic> data = res.data['data'];

          String state = data['state'];
          String responseCode = data['responseCode'];
          String transactionId = data['transactionId'];

          tix = tix.copyWith(
              isCompleted: true,
              isSuccess: true,
              merchantTransactionId: merchantTransactionId,
              transactionId: transactionId,
              transactionResponseCode: responseCode,
              result: res.data['message']
          );
          await FirestoreHelper.pushTix(tix);
          return true;

        } else if(code == 'PAYMENT_ERROR') {
          Logx.i(_TAG, 'payment error');

          Map<String, dynamic> data = res.data['data'];

          String transactionId = data['transactionId'];
          String responseCode = data['responseCode'];

          tix = tix.copyWith(
              isCompleted: true,
              isSuccess: false,
              transactionId: transactionId,
              transactionResponseCode: responseCode,
              result: res.data['message']
          );
          await FirestoreHelper.pushTix(tix);
          return true;

        } else if(code == 'INTERNAL_SERVER_ERROR'){
          Logx.i(_TAG, 'internal server error');

          tix = tix.copyWith(
              isCompleted: true,
              isSuccess: false,
              result: res.data['message']
          );
          await FirestoreHelper.pushTix(tix);

          return true;
        } else {
          //nothing to do
          Logx.i(_TAG, 'transaction is in progress...');
          return false;
        }
      } else {
        Logx.em(_TAG, 'failed with response code : ${res.statusCode} : ${res.toString()}');

        return false;
      }
    } catch (e){
      Logx.em(_TAG, e.toString());
      return 'error';
    }
  }

  /** test mode **/

  static Future<String> startTestTransaction(Tix tix) async {
    Logx.i(_TAG, 'phone pe web start test transaction');

    final Map<String, dynamic> requestData = {
      "merchantId": Constants.testMerchantId,
      "merchantTransactionId": tix.merchantTransactionId,
      "merchantUserId": UserPreferences.myUser.id,
      "amount": (NumberUtils.roundDouble(tix.total, 2) * 100).toInt(),
      "redirectUrl": "http://bloc.bar",
      "redirectMode": "REDIRECT",
      "callbackUrl": "https://webhook.site/5c3f7757-89a5-4c06-8eae-c92e898a852c",
      "mobileNumber": '${UserPreferences.myUser.phoneNumber}',
      "paymentInstrument": {
        "type": "PAY_PAGE"
      },
    };

    String request = ApiHelper.encodeJsonToBase64(requestData);
    Logx.d(_TAG, 'request: $request');

    String saltKey = Constants.testSaltKey;
    String saltIndex = Constants.testSaltIndex;
    //String checksum = sha256(base64Body + apiEndPoint + salt) + ### + saltIndex;
    String checksum = '${sha256.convert(utf8.encode(request
        + Constants.phonePeApiEndPoint + saltKey))}###$saltIndex';
    Logx.d(_TAG, 'checksum: $checksum');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'X-VERIFY': checksum,
    };

    try{
      Dio dio = Dio();

      Response res = await dio.post(Constants.apiTestHostUrl,
          options: Options(headers: headers),
          data: {
            "request": request
      });

      if (res.statusCode == 200) {
        Logx.i(_TAG, 'response code 200 success');

        PhonePeApiResponseData data = PhonePeApiResponseData.fromJson(res.data['data']);
        String transactUrl = data.instrumentResponse!.redirectInfo!.url!;
        Logx.d(_TAG, 'transact url : $transactUrl');

        // final uri = Uri.parse(transactUrl);
        // NetworkUtils.launchInAppBrowser(uri);

        return transactUrl;
      } else {
        Logx.em(_TAG, 'failed with response code : ${res.statusCode}');
        return '${res.statusCode}';
      }
    } catch (e){
      Logx.em(_TAG, e.toString());
      return 'error';
    }
  }

  static Future<bool> testCheckStatus(Tix tix) async {
    String merchantTransactionId = tix.merchantTransactionId;
    String saltKey = Constants.testSaltKey;
    String saltIndex = Constants.testSaltIndex;

    String check = '/pg/v1/status/${Constants.testMerchantId}/$merchantTransactionId$saltKey';
    String checksum = '${sha256.convert(utf8.encode(check))}###$saltIndex';
    Logx.d(_TAG, 'testCheckStatus checksum: $checksum');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'X-VERIFY': checksum,
      'X-MERCHANT-ID': Constants.testMerchantId,
    };

    try{
      Dio dio = Dio();

      String checkStatusUrl  = '${Constants.testCheckStatusUrl}/${Constants.testMerchantId}/$merchantTransactionId';

      Response res = await dio.get(checkStatusUrl,
          options: Options(headers: headers),
        data: {}
      );

      if (res.statusCode == 200) {
        Logx.i(_TAG, 'response code 200 success');

        String code = res.data['code'];

        if(code == 'PAYMENT_SUCCESS'){
          Map<String, dynamic> data = res.data['data'];

          String state = data['state'];
          String responseCode = data['responseCode'];
          String transactionId = data['transactionId'];

          tix = tix.copyWith(
              isCompleted: true,
              isSuccess: true,
              merchantTransactionId: merchantTransactionId,
              transactionId: transactionId,
              transactionResponseCode: responseCode,
              result: res.data['message']
          );
          await FirestoreHelper.pushTix(tix);
          return true;

        } else if(code == 'PAYMENT_ERROR') {
          Map<String, dynamic> data = res.data['data'];

          String transactionId = data['transactionId'];
          String responseCode = data['responseCode'];

          tix = tix.copyWith(
              isCompleted: true,
              isSuccess: false,
              transactionId: transactionId,
              transactionResponseCode: responseCode,
              result: res.data['message']
          );
          await FirestoreHelper.pushTix(tix);
          return true;

        } else if(code == 'INTERNAL_SERVER_ERROR'){
          tix = tix.copyWith(
              isCompleted: true,
              isSuccess: false,
              result: res.data['message']
          );
          await FirestoreHelper.pushTix(tix);

          return true;
        } else {
          //nothing to do
          Logx.d(_TAG, 'transaction is in progress...');
          return false;
        }

        // PhonePeApiResponseData data = PhonePeApiResponseData.fromJson(res.data['data']);
        // String transactUrl = data.instrumentResponse!.redirectInfo!.url!;
        // Logx.i(_TAG, 'transact url : $transactUrl');

        // final uri = Uri.parse(transactUrl);
        // NetworkUtils.launchInAppBrowser(uri);

        // return res.toString();
      } else {
        Logx.em(_TAG, 'failed with response code : ${res.statusCode} : ${res.toString()}');

        return false;
      }
    } catch (e){
      Logx.em(_TAG, e.toString());
      return false;
    }
  }

  static Future<void> _showErrorDialog(BuildContext context, String error) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Constants.lightPrimary,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(19.0))),
          contentPadding: const EdgeInsets.all(16.0),
          title: const Text(
            'transaction api error',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, color: Colors.black),
          ),
          content: Text(
              'error: $error'),
          actions: [
            TextButton(
              child: const Text("close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}