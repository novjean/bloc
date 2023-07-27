import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/logx.dart';

class PartyGuestPreferences {
  static const String _TAG = 'PartyGuestPreferences';

  static late SharedPreferences _preferences;

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  static const _keyListGuestNames = 'list_guest_names';

  static Future setListGuestNames(List<String> listGuestNames) async {
    await _preferences.setStringList(_keyListGuestNames, listGuestNames);
  }

  static List<String> getListGuestNames() {
    List<String> list = [];
    try{
      list = _preferences.getStringList(_keyListGuestNames)!;
    } catch(e){
      Logx.em(_TAG, e.toString());
    }
    return list;
  }

}