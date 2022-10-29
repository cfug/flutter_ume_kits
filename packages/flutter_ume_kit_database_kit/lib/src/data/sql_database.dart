import 'package:flutter_ume_kit_database_kit/src/data/databases.dart';
import 'package:sqflite/sqflite.dart';

///sqlite database update nned conditions
/// db is sqlite database
/// the example is incomplate!!
///
/// db.insert('test', {"table_name": "zhang", "table_size": 12,'tid':1});
///  db.insert('test', {"table_name": "zhang", "table_size": 12,"tid":2});
/// }, updateMap: [
/// {   'test':
///         SqliteUpdateConditions(updateNeedWhere: 'tid = ?', updateNeedcolumnKey: ['tid'])
///  }
///
class SqliteUpdateConditions implements UpdateConditions {
  SqliteUpdateConditions(
      {required this.updateNeedWhere, required this.updateNeedcolumnKey});

  /// ```
  /// custom updaste
  /// int count = await db.update(tableTodo, todo.toMap(),
  ///    where: '$updateNeedWhere = ?', whereArgs: [map[updateNeedcolumnKey]]);
  /// ```
  final String updateNeedWhere;

  /// all column are immutable
  final List<String> updateNeedcolumnKey;

  @override
  String get getUpdateNeedWhere => updateNeedWhere;

  @override
  List<String> get getUpdateNeedcolumnKey => updateNeedcolumnKey;
}

class SqliteDatabas implements UMEDatabase {
  Database? db;
  SqliteDatabas(this._databaseName,
      {this.path,
      this.isDeleteDB = true,
      this.onConfigure,
      this.onCreate,
      this.onDowngrade,
      this.onUpgrade,
      this.onOpen,
      this.updateMap = const []});
  bool isDeleteDB;
  String? path;
  OnDatabaseConfigureFn? onConfigure;
  OnDatabaseCreateFn? onCreate;
  OnDatabaseVersionChangeFn? onUpgrade;
  OnDatabaseVersionChangeFn? onDowngrade;
  OnDatabaseOpenFn? onOpen;
  // key is table
  List<Map<TableName, SqliteUpdateConditions>> updateMap;
  final String _databaseName;
  @override
  String get databaseName => _databaseName;
  @override
  String? get databasePath => path;

  @override
  bool deleteDB() {
    return isDeleteDB;
  }
}

/// sqlite data
class SqliteTableData implements TableData {
  SqliteTableData(this._tableName,
      {this.createSql,
      this.rootpage = 0,
      this.name,
      this.type,
      required this.columnData});
  final String _tableName;
  final String? createSql;
  final int rootpage;
  final String? type;
  final String? name;
  final List<SqliteTableColumData> columnData;

  @override
  String tableName() {
    return _tableName;
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "Table_Name": _tableName,
      "Create_SQL": createSql,
      "rootPage": rootpage,
      "type": type,
      "name": name,
      "Table_Colum": columnData.map((e) => e.columnName()).toList()
    };
  }
}

class SqliteTableColumData implements CloumnData {
  SqliteTableColumData(
      {required this.cid,
      required this.dfltValue,
      required this.type,
      required this.name,
      required this.notnull,
      required this.pk});

  final int cid;
  final String name;
  final String type;
  final int? pk;
  final int? notnull;
  final dynamic dfltValue;

  @override
  String columnName() {
    return name;
  }
}
