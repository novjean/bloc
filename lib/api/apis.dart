import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart';

import '../utils/logx.dart';

class Apis{
  static const String _TAG = 'Apis';

  static Future<void> sendPushNotification(String fcmToken, String title, String msg) async {
    try{
      final body = {
        "to": fcmToken,
        "notification": {
          "title": title, //our name should be send
          "body": msg,
          "android_channel_id": "chats"
        },
        // "data": {
        //   "some_data": "User ID: ${me.id}",
        // },
      };

      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
            'key=AAAATF6Gr-0:APA91bGmS4id_lc7RP9cU2V_kj5VFEgff2bwWG7bwXwTHwFu-OCaPUd77IZgprcuYBD4h68hz7wRpKvTjSAB1sKn3Ak994bbva4lmErUqfuFUIU_UBabtUtkVNYiA9E7dTeK9Qvl_PMR'
          },
          body: jsonEncode(body));
      Logx.i(_TAG, 'Response status: ${res.statusCode}');
      Logx.i(_TAG, 'Response body: ${res.body}');

      Logx.i(_TAG, await read(Uri.https('example.com', 'foobar.txt')));
    } catch(e) {
      Logx.em(_TAG, e.toString());
    }

  }
}