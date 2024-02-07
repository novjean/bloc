import 'dart:convert';
import 'package:bloc/db/ext_entity/phone_pe_api_response_data.dart';
import 'package:bloc/utils/network_utils.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import '../db/entity/tix.dart';
import '../db/shared_preferences/user_preferences.dart';
import '../utils/constants.dart';
import '../utils/logx.dart';

class PhonePeApiService {
  static const String _TAG = 'PhonePeApiService';

  // static String merchantId = Constants.merchantId;
  // static String merchantTransactionId = DateTime.now().millisecondsSinceEpoch.toString();

  // static String checksum = "";
  // static String saltKey = Constants.saltKey;
  // static String saltIndex = Constants.saltIndex;

  static String callbackUrl =
      "https://webhook.site/a7f51d09-7db9-433d-8a6a-45571b725e4b";
  static String redirectUrl = "https://www.bloc.bar";

  String body = "";
  static String apiEndPoint = Constants.phonePeApiEndPoint;

  static double igst = 0;
  static double subTotal = 0;
  static double bookingFee = 0;
  static double grandTotal = 0;

  static getChecksum(){
    String merchantId = Constants.testMerchantId;
    String saltKey = Constants.testSaltKey;
    String saltIndex = Constants.saltIndex;

    String merchantTransactionId = DateTime.now().millisecondsSinceEpoch.toString();
    // int amount = (NumberUtils.roundDouble(grandTotal, 2) * 100).toInt();
    String merchantUserId = UserPreferences.myUser.id;
    String mobileNumber = UserPreferences.myUser.phoneNumber.toString();

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

    //String checksum = sha256(base64Body + apiEndPoint + salt) + ### + saltIndex;
    String base64Body = base64.encode(utf8.encode(json.encode(requestData)));
    String checksum = '${sha256.convert(utf8.encode(base64Body + apiEndPoint + saltKey))}###$saltIndex';

    return 'd7a8e4458caa6fcd781166bbdc85fec76740c18cb9baa9a4c48cf2387d554180###1';
    // return checksum;
  }

  static Future<String> startTransaction() async {
    Logx.i(_TAG, 'phone pe start web transaction');

    String url = Constants.apiIntegrationTestHostUrl;

    // double tixTotal = 100;

    // igst = tixTotal * Constants.igstPercent;
    // subTotal = tixTotal - igst;
    // bookingFee = tixTotal * Constants.bookingFeePercent;
    // grandTotal = subTotal + igst + bookingFee;

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      // 'Access-Control-Allow-Origin': '*',
      'X-VERIFY': getChecksum(),
    };

    try{
      Dio dio = Dio();

      Response res = await dio.post(url,
          options: Options(headers: headers),
          data: {
            "request":"ewogICJtZXJjaGFudElkIjogIlBHVEVTVFBBWVVBVCIsCiAgIm1lcmNoYW50VHJhbnNhY3Rpb25JZCI6ICJNVDc4NTA1OTAwNjgxODgxMDQiLAogICJtZXJjaGFudFVzZXJJZCI6ICJNVUlEMTIzIiwKICAiYW1vdW50IjogMTAwMDAsCiAgInJlZGlyZWN0VXJsIjogImh0dHBzOi8vd2ViaG9vay5zaXRlL3JlZGlyZWN0LXVybCIsCiAgInJlZGlyZWN0TW9kZSI6ICJSRURJUkVDVCIsCiAgImNhbGxiYWNrVXJsIjogImh0dHBzOi8vd2ViaG9vay5zaXRlL2NhbGxiYWNrLXVybCIsCiAgIm1vYmlsZU51bWJlciI6ICI5OTk5OTk5OTk5IiwKICAicGF5bWVudEluc3RydW1lbnQiOiB7CiAgICAidHlwZSI6ICJQQVlfUEFHRSIKICB9Cn0="
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
        return '';
      }
    } catch (e){
      Logx.em(_TAG, e.toString());
      return 'e';
    }
  }
}