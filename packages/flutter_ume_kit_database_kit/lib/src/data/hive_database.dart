import 'package:flutter_ume_kit_database_kit/src/data/databases.dart';
import 'package:hive/hive.dart';

class HiveDatabase implements UMEDatabase {
  HiveDatabase(this.boxItems)
      : assert(boxItems.isNotEmpty, 'the box name must  has one');

  ///hive需要打开的盒子
  List<HiveBoxItem> boxItems;
  @override
  String get databaseName => "Hive";
  @override
  String? get databasePath => null;

  @override
  bool deleteDB() {
    return false;
  }
}

class HiveBoxItem<T extends UMEHiveData> {
  final String name;
  final Box<T> box;
  HiveBoxItem({required this.name, required this.box});
}

class HiveTableData<T extends UMEHiveData> implements TableData {
  HiveTableData(this._tableName, {required this.box});
  final String _tableName;
  final Box<UMEHiveData> box;
  @override
  String tableName() {
    return _tableName;
  }

  @override
  Map<String, dynamic> toJson() {
    var length = box.values.length;

    return <String, dynamic>{
      "Table_Name": _tableName,
      "Data_SIZE": length,
    };
  }
}

class HiveColumnData implements CloumnData {
  HiveColumnData({required this.name});
  final String name;
  @override
  String columnName() {
    return name;
  }
}

/// an ume hive data
/// use ume data class need extends the mixin
/// we need an public function call
/// example:
///
///```
///@HiveType(typeId: 0)
///class Person with UMEHiveData {
///  Person({required this.age, required this.name});
///  @HiveField(0)
///  String name;
///  @HiveField(1)
///  int age;

///  @override
///  Map<String, dynamic> toJson() {
///    return <String, dynamic>{'name': name, 'age': age};
///  }
///}
mixin UMEHiveData {
  Map<String, dynamic> toJson();
}
