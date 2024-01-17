import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/constants.dart';
import '../../utils/logx.dart';
import '../entity/user.dart';

class UserPreferences {
  static const String _TAG = 'UserPreferences';

  static late SharedPreferences _preferences;

  static const _keyUser = 'user';

  static const _keyVerificationId = 'verification_id';

  static Future setVerificationId(String verificationId) async {
    await _preferences.setString(_keyVerificationId, verificationId);
  }

  static String getVerificationId() {
    return _preferences.getString(_keyVerificationId)!;
  }

  static const _keyUserBlocId = 'user_bloc_id';

  static Future setBlocId(String blocId) async {
    await _preferences.setString(_keyUserBlocId, blocId);
  }

  static String getBlocId() {
    return _preferences.getString(_keyUserBlocId)!;
  }

  static const _keyListLounges = 'list_lounges';

  static Future setListLounges(List<String> listLounges) async {
    await _preferences.setStringList(_keyListLounges, listLounges);
  }

  static List<String> getListLounges() {
    List<String> list = [];
    try{
      list = _preferences.getStringList(_keyListLounges)!;
    } catch(e){
      Logx.em(_TAG, e.toString());
    }
    return list;
  }

  static const _keyUserBlocs = 'user_blocs';

  static Future setUserBlocs(List<String> listBlocs) async {
    await _preferences.setStringList(_keyUserBlocs, listBlocs);
  }

  static List<String> getUserBlocs() {
    List<String> list = [];
    try{
      list = _preferences.getStringList(_keyUserBlocs)!;
    } catch(e){
      Logx.em(_TAG, e.toString());
    }
    return list;
  }

  static var myUser = User(
      id: '',
      email: '',
      imageUrl: '',
      clearanceLevel: 0,
      challengeLevel: 1,
      phoneNumber: 1,
      birthYear: 2023,
      name: '',
      surname: '',
      username: '',
      instagramLink: '',
      gender: 'male',
      fcmToken: '',
      blocServiceId: '',
      createdAt: 0,
      lastSeenAt: 0,
      isBanned: false,
      isAppUser: false,
      isIos: false,
      isAppReviewed: false,
      lastReviewTime: 0,
      appVersion: Constants.appVersion);

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

  static void resetUser(int phoneNumber) {
    setUser(User(
        id: '',
        email: '',
        imageUrl: '',
        clearanceLevel: 0,
        challengeLevel: 1,
        phoneNumber: phoneNumber,
        birthYear: 2023,
        name: '',
        surname: '',
        username: '',
        instagramLink: '',
        gender: '',
        fcmToken: '',
        blocServiceId: '',
        createdAt: 0,
        lastSeenAt: 0,
        isBanned: false,
        isAppUser: false,
        isIos: false,
        isAppReviewed: false,
        lastReviewTime: 0,
        appVersion: Constants.appVersion));

    setListLounges([]);
    setUserBlocs([]);
  }

  static void setUserFcmToken(String token) {
    myUser.fcmToken = token;
  }

  static bool isUserLoggedIn() {
    return myUser.phoneNumber == 911234567890
        || myUser.phoneNumber == 0
        || myUser.phoneNumber == 1
        ? false
        : true;
  }
}
