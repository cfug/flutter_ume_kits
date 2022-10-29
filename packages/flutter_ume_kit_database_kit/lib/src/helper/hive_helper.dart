import 'package:flutter_ume_kit_database_kit/src/data/databases.dart';
import 'package:flutter_ume_kit_database_kit/src/data/hive_database.dart';
import 'package:flutter_ume_kit_database_kit/src/helper/helpers.dart';
import 'package:hive/hive.dart';

class HiveHelper implements UmeDatabaseHelper {
  Future<List<TableData>> findAllTable(HiveDatabase database) async {
    List<TableData> tableDatas = [];
    for (var boxItem in database.boxItems) {
      tableDatas.add(HiveTableData(boxItem.name, box: boxItem.box));
    }
    return tableDatas;
  }

  Future<List<Map<String, dynamic>>> findSingleBoxData(
      Box<UMEHiveData> box) async {
    List<Map<String, dynamic>> datas = [];
    // print(box.values);
    datas = box.values.map((d) => d.toJson()).toList();
    return datas;
  }
}
