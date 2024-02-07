import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
// import 'package:http/http.dart';
import '../db/entity/tix.dart';
import '../db/shared_preferences/user_preferences.dart';
import '../utils/constants.dart';
import '../utils/logx.dart';
import '../utils/number_utils.dart';

class HttpService {
  static const String _TAG = 'HttpService';

  static String merchantId = Constants.merchantId;
  static String merchantTransactionId = DateTime.now().millisecondsSinceEpoch.toString();

  static String checksum = "";
  static String saltKey = Constants.saltKey;
  static String saltIndex = Constants.saltIndex;

  static String callbackUrl =
      "https://webhook.site/a7f51d09-7db9-433d-8a6a-45571b725e4b";
  static String redirectUrl =
      "https://www.bloc.bar";

  String body = "";
  static String apiEndPoint = Constants.phonePeApiEndPoint;

  Object? result;

  static double igst = 0;
  static double subTotal = 0;
  static double bookingFee = 0;
  static double grandTotal = 0;

  static getChecksum(){
    int amount = (NumberUtils.roundDouble(grandTotal, 2) * 100).toInt();
    String merchantUserId = UserPreferences.myUser.id;
    String mobileNumber = UserPreferences.myUser.phoneNumber.toString();
    merchantTransactionId = DateTime.now().millisecondsSinceEpoch.toString();

    final requestData = {
      "merchantId": merchantId,
      "merchantTransactionId": merchantTransactionId,
      "merchantUserId": merchantUserId,
      "amount": amount,
      "redirectUrl": redirectUrl,
      "redirectMode": "REDIRECT",
      "callbackUrl": callbackUrl,
      "mobileNumber": mobileNumber,
      "paymentInstrument": {
        "type": "PAY_PAGE",
      },
    };

    // saltKey = Constants.testSaltKey;

    //String checksum = sha256(base64Body + apiEndPoint + salt) + ### + saltIndex;
    String base64Body = base64.encode(utf8.encode(json.encode(requestData)));
    checksum = '${sha256.convert(utf8.encode(base64Body + apiEndPoint + saltKey)).toString()}###$saltIndex';

    return checksum;
  }

  static Future<void> startTransaction() async {
    Logx.i(_TAG, 'phone pe start web transaction');

    String url = "https://api-preprod.phonepe.com/apis";
    url = Constants.apiIntegrationTestHostUrl;

    double tixTotal = 100;

    igst = tixTotal * Constants.igstPercent;
    subTotal = tixTotal - igst;
    bookingFee = tixTotal * Constants.bookingFeePercent;
    grandTotal = subTotal + igst + bookingFee;

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      // 'Access-Control-Allow-Origin': '*',
      'X-VERIFY': getChecksum(),
    };

    try{
      Dio dio = Dio();
      // dio.options.headers['Access-Control-Allow-Origin'] = '*';

      Response res = await dio.post(url,
          options: Options(headers: headers),
          );

      if (res.statusCode == 200) {
        // List<dynamic> body = jsonDecode(res.body);

        // List<User> posts = body
        //     .map(
        //       (dynamic item) => User.fromJson(item),
        // )
        //     .toList();

        return ;
      } else {
        Logx.em(_TAG, 'failed with response code : ${res.statusCode}');
      }
    } catch (e){
      Logx.em(_TAG, e.toString());
    }
  }
}