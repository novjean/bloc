// ignore_for_file: require_trailing_commas

import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../db/entity/user.dart';
import 'firestore_helper.dart';

/// Manages & returns the users FCM token.
///
/// Also monitors token refreshes and updates state.
class TokenMonitor extends StatefulWidget {
  // ignore: public_member_api_docs
  TokenMonitor(this._builder);

  final Widget Function(String? token) _builder;

  @override
  State<StatefulWidget> createState() => _TokenMonitor();
}

class _TokenMonitor extends State<TokenMonitor> {
  String? _token;
  late Stream<String> _tokenStream;

  void setToken(String? token) {
    print('FCM Token: $token');
    setState(() {
      _token = token;

      User user = UserPreferences.getUser();
      UserPreferences.setUserFcmToken(_token!);
      FirestoreHelper.updateUserFcmToken(user.id, token);
    });
  }

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance
        .getToken()
    // if vapidKey is needed, then : https://stackoverflow.com/questions/54996206/firebase-cloud-messaging-where-to-find-public-vapid-key
        // vapidKey:
        // 'BGpdLRsMJKvFDD9odfPk92uBg-JbQbyoiZdah0XlUyrjG4SDgUsE1iC_kdRgt4Kn0CO7K3RTswPZt61NNuO0XoA')
        .then(setToken);
    _tokenStream = FirebaseMessaging.instance.onTokenRefresh;
    _tokenStream.listen(setToken);
  }

  @override
  Widget build(BuildContext context) {
    return widget._builder(_token);
  }
}
