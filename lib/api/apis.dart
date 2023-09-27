import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

import '../utils/logx.dart';

class Apis{
  static const String _TAG = 'Apis';

  static const String GoogleReviewBloc = 'google_review_bloc';
  static const String GoogleReviewFreq = 'google_review_freq';

  static Future<void> sendPushNotification(String fcmToken, String title, String msg) async {
    try{
      final body = {
        "to": fcmToken,
        "android_channel_id": "high importance",
        "notification": {
          "title": title, //our name should be send
          "body": msg,
        },
        "priority": "normal"
      };

      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
            'key=AAAATF6Gr-0:APA91bGmS4id_lc7RP9cU2V_kj5VFEgff2bwWG7bwXwTHwFu-OCaPUd77IZgprcuYBD4h68hz7wRpKvTjSAB1sKn3Ak994bbva4lmErUqfuFUIU_UBabtUtkVNYiA9E7dTeK9Qvl_PMR'
          },
          body: jsonEncode(body));
      Logx.i(_TAG, 'Response status: ${res.statusCode == 200? 'success':'failure'}');
      Logx.i(_TAG, 'Response body: ${res.body}');
    } catch(e) {
      Logx.em(_TAG, e.toString());
    }
  }

  static Future<void> sendChatNotification(String fcmToken, String title, String msg) async {
    try{
      final body = {
        "to": fcmToken,
        "android_channel_id": "high importance",
        "notification": {
          "title": title,
          "body": msg,
        },
        "priority": "normal"
      };

      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
            'key=AAAATF6Gr-0:APA91bGmS4id_lc7RP9cU2V_kj5VFEgff2bwWG7bwXwTHwFu-OCaPUd77IZgprcuYBD4h68hz7wRpKvTjSAB1sKn3Ak994bbva4lmErUqfuFUIU_UBabtUtkVNYiA9E7dTeK9Qvl_PMR'
          },
          body: jsonEncode(body));
      Logx.i(_TAG, 'Response status: ${res.statusCode == 200? 'success':'failure'}');
      Logx.i(_TAG, 'Response body: ${res.body}');
    } catch(e) {
      Logx.em(_TAG, e.toString());
    }
  }

  static Future<void> sendUrlMinimalNotification(String fcmToken, String type, String url) async {
    try{
      final body = {
        "to": fcmToken,
      "android_channel_id": "high importance",
      "notification": {
          "title": '',
          "body": '',
        },
        "data": {
          "type": type,
          "link": url
        },
        "priority": "normal"
      };

      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
            'key=AAAATF6Gr-0:APA91bGmS4id_lc7RP9cU2V_kj5VFEgff2bwWG7bwXwTHwFu-OCaPUd77IZgprcuYBD4h68hz7wRpKvTjSAB1sKn3Ak994bbva4lmErUqfuFUIU_UBabtUtkVNYiA9E7dTeK9Qvl_PMR'
          },
          body: jsonEncode(body));
      Logx.i(_TAG, 'Response status: ${res.statusCode == 200? 'success':'failure'}');
      Logx.i(_TAG, 'Response body: ${res.body}');

      // Logx.i(_TAG, await read(Uri.https('example.com', 'foobar.txt')));
    } catch(e) {
      Logx.em(_TAG, e.toString());
    }
  }

  static Future<void> sendUrlData(String fcmToken, String type, String url) async {
    try{
      final body = {
        "to": fcmToken,
        "android_channel_id": "high importance",
        "data": {
          "type": type,
          "link": url
        },
        "priority": "normal"
      };

      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
            'key=AAAATF6Gr-0:APA91bGmS4id_lc7RP9cU2V_kj5VFEgff2bwWG7bwXwTHwFu-OCaPUd77IZgprcuYBD4h68hz7wRpKvTjSAB1sKn3Ak994bbva4lmErUqfuFUIU_UBabtUtkVNYiA9E7dTeK9Qvl_PMR'
          },
          body: jsonEncode(body));
      Logx.i(_TAG, 'Response status: ${res.statusCode == 200? 'success':'failure'}');
      Logx.i(_TAG, 'Response body: ${res.body}');

      // Logx.i(_TAG, await read(Uri.https('example.com', 'foobar.txt')));
    } catch(e) {
      Logx.em(_TAG, e.toString());
    }
  }

}