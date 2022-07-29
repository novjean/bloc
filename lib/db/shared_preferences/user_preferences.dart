import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../entity/user.dart';

class UserPreferences {
  static late SharedPreferences _preferences;

  static const _keyUser = 'user';

  static var myUser = User(
      id: '',
      username: '',
      email: '',
      imageUrl:'',
      clearanceLevel: 0,
      phoneNumber: 0,
      name: '',
      fcmToken: '', blocServiceId: '');

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  static Future setUser(User user) async {
    final json = jsonEncode(user.toMap());
    await _preferences.setString(_keyUser, json);
  }

  static User getUser() {
    final json = _preferences.getString(_keyUser);

    return json == null ? myUser : User.fromMap(jsonDecode(json));
  }

  static void resetUser() {
    setUser(User(
        id: '',
        username: '',
        email: '',
        imageUrl: '',
        clearanceLevel: 0,
        phoneNumber: 0,
        name: '',
        fcmToken: '', blocServiceId: ''));
  }
}
