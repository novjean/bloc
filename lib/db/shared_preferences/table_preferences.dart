import 'dart:convert';

import 'package:bloc/db/entity/service_table.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TablePreferences {
  static late SharedPreferences _preferences;

  static const _keyTable = 'table';

  static var myTable = ServiceTable(
      id: '',
      serviceId: '',
      tableNumber: 0,
      capacity: 0,
      isOccupied: false,
      colorStatus: 0);

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  static Future setTable(ServiceTable table) async {
    final json = jsonEncode(table.toMap());
    await _preferences.setString(_keyTable, json);
  }

  static ServiceTable getTable() {
    final json = _preferences.getString(_keyTable);

    return json == null ? myTable : ServiceTable.fromMap(jsonDecode(json));
  }

  static void resetUser() {
    setTable(ServiceTable(
        id: '',
        serviceId: '',
        tableNumber: 0,
        capacity: 0,
        isOccupied: false,
        colorStatus: 0));
  }
}
