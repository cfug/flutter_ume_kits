import 'package:flutter_ume_kit_database_kit/src/data/databases.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesDatabase implements UMEDatabase {
  SharedPreferencesDatabase(this._databaseName,
      {required this.sharedPreferences, isDedeteDB = true})
      : _isDedeteDB = isDedeteDB,
        super();
  final String _databaseName;
  final bool _isDedeteDB;

  late final SharedPreferencesTableData tableData =
      SharedPreferencesTableData(_databaseName, sharedPreferences);

  SharedPreferences sharedPreferences;

  @override
  String get databaseName => _databaseName;

  @override
  String? get databasePath => null;

  ///if it return true,it will clear
  @override
  bool deleteDB() {
    return _isDedeteDB;
  }
}

enum ColumnDataType { string, int, double, bool, list, invalid }

class SharedPreferencesTableData implements TableData {
  SharedPreferencesTableData(this._tableName, this._preferences);
  final String? _tableName;
  final SharedPreferences _preferences;

  List<SharedPreferencesColumnData> columns = [
    SharedPreferencesColumnData('key'),
    SharedPreferencesColumnData('value')
  ];

  Map<String, ColumnDataType> columnDataType = {};

  @override
  String tableName() {
    return _tableName ?? "SharedPreferences";
  }

  @override
  Map<String, dynamic> toJson() {
    var size = _preferences.getKeys().length;

    return {
      'Table_Name': _tableName ?? "SharedPreferences",
      "TableSize": size,
      "allKey": _preferences.getKeys()
    };
  }
}

class SharedPreferencesColumnData implements CloumnData {
  SharedPreferencesColumnData(this.name);
  final String name;
  @override
  String columnName() {
    return name;
  }
}

class SharedPreferencesUpdateConditions implements UpdateConditions {
  @override
  String? get getUpdateNeedWhere => null;

  @override
  List<String>? get getUpdateNeedcolumnKey => null;
}
