import 'package:shared_preferences/shared_preferences.dart';

import '../../routes/route_constants.dart';
import '../../utils/logx.dart';

class UiPreferences{
  static const String _TAG = 'UiPreferences';

  static late SharedPreferences _preferences;


  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  static const _keyPageIndex = 'page_index';

  static Future setHomePageIndex(int pageIndex) async {
    await _preferences.setInt(_keyPageIndex, pageIndex);
  }

  static int getHomePageIndex() {
    int index = 0;
    try {
      index = _preferences.getInt(_keyPageIndex)!;
    } catch(e) {
      Logx.em(_TAG, e.toString());
    }
    return index;
  }

  static const _keyLastHomeAdTime = 'last_home_ad_time';

  static Future setLastHomeAdTime(int time) async {
    await _preferences.setInt(_keyLastHomeAdTime, time);
  }

  static int getLastHomeAdTime() {
    int time = 0;
    try {
      time = _preferences.getInt(_keyLastHomeAdTime)!;
    } catch(e) {
      Logx.em(_TAG, 'last home ad time has not been setup');
    }
    return time;
  }

  static const _keyRouteName = RouteConstants.landingRouteName;

  static Future setRoute(String routeName) async {
    await _preferences.setString(_keyRouteName, routeName);
  }

  static String getRoute() {
    return _preferences.getString(_keyRouteName)!;
  }

  static const _keyEventName = '';

  static Future setEventName(String eventName) async {
    await _preferences.setString(_keyEventName, eventName);
  }

  static String getEventName() {
    return _preferences.getString(_keyEventName)!;
  }
  static const _keyEventChapter = '';

  static Future setEventChapter(String eventChapter) async {
    await _preferences.setString(_keyEventChapter, eventChapter);
  }

  static String getEventChapter() {
    return _preferences.getString(_keyEventChapter)!;
  }

}