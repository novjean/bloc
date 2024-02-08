import 'dart:convert';
import 'package:bloc/db/ext_entity/phone_pe_api_response_data.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import '../db/entity/tix.dart';
import '../db/shared_preferences/user_preferences.dart';
import '../utils/constants.dart';
import '../utils/logx.dart';
import '../utils/number_utils.dart';

class PhonePeApiService {
  static const String _TAG = 'PhonePeApiService';

  static String callbackUrl =
      "https://webhook.site/a7f51d09-7db9-433d-8a6a-45571b725e4b";
  static String redirectUrl = "https://www.bloc.bar";

  static getChecksum(String request){
    String saltKey = Constants.saltKey;
    String saltIndex = Constants.saltIndex;

    //String checksum = sha256(base64Body + apiEndPoint + salt) + ### + saltIndex;
    String checksum = '${sha256.convert(utf8.encode(request
        + Constants.phonePeApiEndPoint + saltKey))}###$saltIndex';
    return checksum;
  }

  static startTransaction(Tix tix) async {
    Logx.i(_TAG, 'phone pe web start real transaction');

    final requestData = {
      "merchantId": Constants.merchantId,
      "merchantTransactionId": DateTime.now().millisecondsSinceEpoch.toString(),
      "merchantUserId": UserPreferences.myUser.id,
      "amount": (NumberUtils.roundDouble(tix.total, 2) * 100).toInt(),
      "redirectUrl": "https://www.bloc.bar",
      "redirectMode": "REDIRECT",
      "callbackUrl": "https://webhook.site/a7f51d09-7db9-433d-8a6a-45571b725e4b",
      "mobileNumber": '${UserPreferences.myUser.phoneNumber}',
      "paymentInstrument": {
        "type": "PAY_PAGE",
      },
    };

    String request = base64.encode(utf8.encode(json.encode(requestData)));
    Logx.i(_TAG, 'request: $request');

    String checksum = getChecksum(request);
    Logx.i(_TAG, 'checksum: $checksum');

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
        Logx.em(_TAG, 'failed with response code : ${res.statusCode} : ${res.toString()}');

        return '${res.statusCode}';
      }
    } catch (e){
      Logx.em(_TAG, e.toString());
      return 'error';
    }
  }

  static String getTestRequest() {
    final requestData = {
      "merchantId": 'PGTESTPAYUAT',
      "merchantTransactionId": 'MT7850590068188104',
      "merchantUserId": 'MUID123',
      "amount": 10000,
      "redirectUrl": 'https://webhook.site/redirect-url',
      "redirectMode": "REDIRECT",
      "callbackUrl": 'https://webhook.site/callback-url',
      "mobileNumber": '9999999999',
      "paymentInstrument": {
        "type": "PAY_PAGE",
      },
    };

    String base64Body = base64.encode(utf8.encode(json.encode(requestData)));
    return base64Body;
  }

  static String getTestChecksum(String request){
    String saltKey = Constants.testSaltKey;
    String saltIndex = Constants.saltIndex;

    //String checksum = sha256(base64Body + apiEndPoint + salt) + ### + saltIndex;
    String checksum = '${sha256.convert(utf8.encode(request + Constants.phonePeApiEndPoint + saltKey))}###$saltIndex';
    return checksum;

    // return 'd7a8e4458caa6fcd781166bbdc85fec76740c18cb9baa9a4c48cf2387d554180###1';
  }

  static Future<String> startTestTransaction() async {
    Logx.i(_TAG, 'phone pe web start test transaction');

    String request = getTestRequest();
    Logx.d(_TAG, 'request: $request');

    String checksum = getChecksum(request);
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

}