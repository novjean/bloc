import 'dart:convert';

import 'package:bloc/db/entity/service_table.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TablePreferences {
  static late SharedPreferences _preferences;

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  static const _keyTable = 'table';

  static const _keyQuickTable = 'quick_table';

  static Future setQuickTable(String tableName) async {
    await _preferences.setString(_keyQuickTable, tableName);
  }

  static String getQuickTable() {
    return _preferences.getString(_keyQuickTable)!;
  }

  static bool isUserQuickSeated() {
    return getQuickTable().isEmpty?false:true;
  }

  static void resetQuickTable(){
    setQuickTable('');
  }

  static var myTable = ServiceTable(
      id: '',
      serviceId: '',
      captainId: '',
      tableNumber: 0,
      capacity: 0,
      isOccupied: false,
      isActive: true,
      type: FirestoreHelper.TABLE_PRIVATE_TYPE_ID);

  static Future setTable(ServiceTable table) async {
    final json = jsonEncode(table.toMap());
    myTable = table;
    await _preferences.setString(_keyTable, json);
  }

  static ServiceTable getTable() {
    final json = _preferences.getString(_keyTable);

    return json == null ? myTable : ServiceTable.fromMap(jsonDecode(json));
  }

  static void resetTable() {
    setTable(ServiceTable(
        id: '',
        serviceId: '',
        captainId: '',
        tableNumber: 0,
        capacity: 0,
        isOccupied: false,
        isActive: true,
        type: FirestoreHelper.TABLE_PRIVATE_TYPE_ID));
  }
}
