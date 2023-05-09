import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../entity/user.dart';

class UserPreferences {
  static late SharedPreferences _preferences;

  static const _keyUser = 'user';

  static var myUser = User(
      id: '',
      email: '',
      imageUrl: '',
      clearanceLevel: 0,
      challengeLevel: 1,
      phoneNumber: 0,
      name: '',
      surname: '',
      gender: 'male',
      fcmToken: '',
      blocServiceId: '',
      createdAt: 0,
      lastSeenAt: 0);

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  static Future setUser(User user) async {
    final json = jsonEncode(user.toMap());
    myUser = user;
    await _preferences.setString(_keyUser, json);
  }

  static User getUser() {
    final json = _preferences.getString(_keyUser);

    return json == null ? myUser : User.fromMap(jsonDecode(json));
  }

  static void resetUser() {
    setUser(User(
        id: '',
        email: '',
        imageUrl: '',
        clearanceLevel: 0,
        challengeLevel: 1,
        phoneNumber: 0,
        name: '',
        surname: '',
        gender: '',
        fcmToken: '',
        blocServiceId: '',
        createdAt: 0,
        lastSeenAt: 0));
  }

  static void setUserFcmToken(String token) {
    myUser.fcmToken = token;
  }

  static bool isUserLoggedIn() {
    return myUser.phoneNumber == 911234567890 ? false : true;
  }
}
