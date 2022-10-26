import 'package:hive_flutter/hive_flutter.dart';
import 'package:database_kit/database_kit.dart';
import 'data/data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Setup {
  static Future<List<UMEDatabase>> initalizeDatabaseTestCase() async {
    var sqldb = SqliteDatabas('test.db', path: null, isDeleteDB: true,
        onCreate: (db, index) {
      db.execute(
          'create table test (table_name text,table_size integer,tid integer,tid1 integer,tid2 integer)');
      db.execute('create table people (name text,age integer)');
      db.insert('people', {
        "name": "zhangzhangzhangzhangzhangzhangzhangzhangzhangzhangzhang",
        "age": 12
      });
      db.insert('people', {
        "name":
            "zhazhangzhangzhangzhangzhangzhangzhangzhangzhangzhangzhangzhangng",
        "age": 12
      });
      db.insert('people', {
        "name": "zhzhangzhangzhangzhangzhangzhangzhangzhangzhangzhangzhangang",
        "age": 12
      });
      db.insert('test', {
        "table_name": "zhang",
        "table_size": 12,
        'tid': 1,
        'tid1': 1,
        'tid2': 1
      });
      db.insert('test', {"table_name": "zhang", "table_size": 12, "tid": 2});
    }, updateMap: [
      {
        'test': SqliteUpdateConditions(
            updateNeedWhere: 'tid = ?', updateNeedcolumnKey: ['tid'])
      }
    ]);

    ///register hive databases
    await Hive.initFlutter();
    Hive.registerAdapter(PersonAdapter());
    Hive.registerAdapter(TableAdapter());
    Hive.registerAdapter(TestAdapter());
    var pBox = await Hive.openBox<Person>("people");
    var test = await Hive.openBox<Test>("test");
    pBox.put("p", Person(age: 12, name: 'xiaolaing'));
    test.put("p1", Test(age: 13, name: 'xiaolaing'));
    pBox.put("p2", Person(age: 14, name: 'xiaolaing'));

    ///reigster dugeg plugin
    var hive = HiveDatabase(
      [
        HiveBoxItem<Person>(name: 'people', box: pBox),
        HiveBoxItem<Test>(name: 'test', box: test),
      ],
    );

    ///SharedPreferences Database
    var sp = SharedPreferencesDatabase("SP",
        sharedPreferences: await SharedPreferences.getInstance());

    return [sp, hive, sqldb];
  }
}
