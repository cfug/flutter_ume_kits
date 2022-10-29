

/// an string  typedef
typedef TableName = String;

abstract class UMEDatabase {
  String get databaseName;
  String? get databasePath;

  ///每次清空db数据和文件
  bool deleteDB() {
    throw UnimplementedError();
  }
}

/// data update content
abstract class UpdateConditions {
  String? get getUpdateNeedWhere;
  List<String>? get getUpdateNeedcolumnKey;
}


class CustomDtabase extends UMEDatabase {
  CustomDtabase(this._databaseName);
  final String _databaseName;
  @override
  String get databaseName => _databaseName;
  @override
  String? get databasePath => null;
}



abstract class TableData {
  /// if it is sqlite the table name
  /// or if it is hive the box name
  /// or objectdb the name
  String tableName() {
    throw UnimplementedError();
  }

  Map<String, dynamic> toJson();
}

abstract class CloumnData {
  String columnName() {
    throw UnimplementedError();
  }
}
