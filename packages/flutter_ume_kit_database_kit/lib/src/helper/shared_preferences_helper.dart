import 'dart:convert';

import 'package:flutter_ume_kit_database_kit/database_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper extends UmeDatabaseHelper {
  SharedPreferencesHelper(this._sharedPreferences);
  final SharedPreferences _sharedPreferences;
  Set<String> findAllKeys() {
    return _sharedPreferences.getKeys();
  }

  List<Map<String, dynamic>> findAllData(SharedPreferencesTableData tableData) {
    List<Map<String, dynamic>> datas = [];
    var setKey = findAllKeys();
    // print(setKey);
    // var fgs = _sharedPreferences.get('FloatingDotPos');
    // print(fgs);
    for (var key in setKey) {
      var value = _sharedPreferences.get(key);
      if (value is String?) {
        tableData.columnDataType[key] = ColumnDataType.string;
      } else if (value is double?) {
        tableData.columnDataType[key] = ColumnDataType.double;
      } else if (value is int?) {
        tableData.columnDataType[key] = ColumnDataType.int;
      } else if (value is List<String>?) {
        tableData.columnDataType[key] = ColumnDataType.string;
      } else if (value is bool?) {
        tableData.columnDataType[key] = ColumnDataType.bool;
      } else {
        tableData.columnDataType[key] = ColumnDataType.invalid;
      }
      var data = <String, dynamic>{key: value};
      datas.add(data);
    }
    // print(datas);
    return datas;
  }

  Future<bool> updateKey(
      ColumnDataType columnDataType, String key, Object value) async {
    // print(key);
    // print(value);
    // print(columnDataType);
    switch (columnDataType) {
      case ColumnDataType.int:
        return _sharedPreferences.setInt(
            key, int.tryParse(value.toString()) ?? 0);
      case ColumnDataType.bool:
        return _sharedPreferences.setBool(
            key, value.toString().toLowerCase() == 'true');
      case ColumnDataType.list:
        var list = json.decode(value.toString()) as List<dynamic>;
        // print(list);
        return _sharedPreferences.setStringList(
            key, list.map((e) => e.toString()).toList());
      case ColumnDataType.double:
        return _sharedPreferences.setDouble(
            key, double.parse(value.toString()));
      case ColumnDataType.string:
        return _sharedPreferences.setString(key, value.toString());
      case ColumnDataType.invalid:
        throw ('an invalid column data type,check the code is right');
    }
  }
}
