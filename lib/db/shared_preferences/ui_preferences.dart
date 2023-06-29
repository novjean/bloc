import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/logx.dart';

class UiPreferences{
  static const String _TAG = 'UiPreferences';

  static late SharedPreferences _preferences;

  static const _keyPageIndex = 'page_index';

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

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

}