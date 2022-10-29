import 'dart:convert';
import 'dart:math';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter_ume_kit_database_kit/database_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ume/flutter_ume.dart';

import 'data/icon.dart';

class DatabasePanel extends StatefulWidget implements Pluggable {
  ///need developer the databases
  ///sqlite path is null we using databaname create database
  ///if isDeleteDB = [true] to we do delete the db
  ///PluginManager.instance.register(
  ///DatabasePanel(
  ///databases: [
  ///SqliteDatabas('test.db', path: null,,isDeleteDB: true)
  ///]
  ///))
  final List<UMEDatabase> databases;

  const DatabasePanel({Key? key, required this.databases}) : super(key: key);

  @override
  State<DatabasePanel> createState() => _DatabasePanelState();

  @override
  Widget buildWidget(BuildContext? context) {
    return this;
  }

  @override
  String get displayName => "DatabasePanel";

  @override
  ImageProvider<Object> get iconImageProvider =>
      MemoryImage(base64Decode(icon));

  @override
  String get name => "DatabasePanel";

  @override
  void onTrigger() {}
}

class _DatabasePanelState extends State<DatabasePanel>
    with SingleTickerProviderStateMixin {
  final DatabaseManager _databaseManager = DatabaseManager();
  List<bool> selected = [];
  int selectIndex = 0;
  final Color background = Colors.white;
  //current database table datasd
  List<TableData> tableDatas = [];

  //show table column data
  List<Map<String, dynamic>> datas = [];

  ///currentIndex
  int _currentDatabaseIndex = 0;
  int _currentTableIndex = 0;
  DatabaseType? currentDatabaseType;
  //db open successful
  bool dbIsOpen = false;

  OverlayEntry _overlayEntry = OverlayEntry(builder: (ctx) => Container());

  //only show an overlay
  bool isShowOverlay = false;

  @override
  void initState() {
    _openDB();

    super.initState();
  }

  @override
  void dispose() {
    if (_overlayEntry.mounted) {
      _overlayEntry.remove();
    }
    super.dispose();
  }

  ///open database
  _openDB() async {
    ///initialization all database
    await _databaseManager.openDatabases(databases: widget.databases);
    if (_databaseManager.databases.isNotEmpty) {
      //initialization first database
      var databases = _databaseManager.databases[_currentDatabaseIndex];
      if (databases is SqliteDatabas) {
        tableDatas =
            await _databaseManager.sqliteHelper.findAllTableData(databases);
        currentDatabaseType = DatabaseType.sqlite;
        if (tableDatas.isNotEmpty) {}
      } else if (databases is HiveDatabase) {
        tableDatas = await _databaseManager.hiveHelper.findAllTable(databases);
      } else if (databases is SharedPreferencesDatabase) {
        tableDatas = [databases.tableData];
      }
    }
    if (tableDatas.isNotEmpty) {
      _updateTableSelect(tableDatas[0]);
    }
    dbIsOpen = true;
    setState(() {});
  }

  void _updateCurrentDatabaseType() {
    var databases = _databaseManager.databases[_currentDatabaseIndex];
    if (databases is SqliteDatabas) {
      currentDatabaseType = DatabaseType.sqlite;
    } else if (databases is HiveDatabase) {
      currentDatabaseType = DatabaseType.hive;
    } else if (databases is CustomDtabase) {
      currentDatabaseType = DatabaseType.customDB;
    } else if (databases is SharedPreferencesDatabase) {
      currentDatabaseType = DatabaseType.sharedPreferences;
    }
    _currentTableIndex = 0;

    ///after the update database mush update table data
    _updateTableSelect(tableDatas[_currentTableIndex]);
  }

  Future<void> _updateDatabaseSelect(UMEDatabase database) async {
    if (database is SqliteDatabas) {
      tableDatas =
          await _databaseManager.sqliteHelper.findAllTableData(database);
    } else if (database is HiveDatabase) {
      tableDatas = await _databaseManager.hiveHelper.findAllTable(database);
    } else if (database is SharedPreferencesDatabase) {
      tableDatas = [database.tableData];
    }
    _updateCurrentDatabaseType();
    setState(() {});
  }

  //listener table data
  Future<void> _updateTableSelect(TableData tableData) async {
    datas.clear();
    if (tableData is SqliteTableData) {
      var dd = await _databaseManager.sqliteHelper
          .findSingleTableAllData(tableData.tableName());
      datas.addAll(dd);
    } else if (tableData is HiveTableData) {
      var dd =
          await _databaseManager.hiveHelper.findSingleBoxData(tableData.box);
      datas.addAll(dd);
    } else if (tableData is SharedPreferencesTableData) {
      var dd = _databaseManager.sharedPreferencesHelper.findAllData(tableData);
      datas.addAll(dd);
    }
    setState(() {});
  }

  ///fliter an map text
  String _fliterShowText(String text) {
    return text.replaceAll(',', '\n').replaceAll('{', '').replaceAll('}', '');
  }

  ///show an overlay entry
  void _showOverlayEntry(Widget child) {
    if (isShowOverlay) return;
    _overlayEntry = OverlayEntry(builder: (context) {
      return child;
    });
    overlayKey.currentState?.insert(_overlayEntry);
    isShowOverlay = true;
  }

  //the hide overlay entry
  void _hideOverlayEntry() {
    if (_overlayEntry.mounted) {
      _overlayEntry.remove();
      isShowOverlay = false;
    }
  }

  //show an simple dialog
  void _showSimleDialog(String text) {
    var child = Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(top: 200, bottom: 200, left: 50, right: 50),
      height: 200,
      width: 200,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.1))
          ]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.left,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ),
          TextButton(
              onPressed: () {
                _hideOverlayEntry();
              },
              child: const Text("关闭"))
        ],
      ),
    );
    _showOverlayEntry(child);
  }

  @override
  Widget build(BuildContext context) {
    if (!dbIsOpen) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (dbIsOpen && _databaseManager.databases.isEmpty) {
      return const Center(
        child: Text('not find database'),
      );
    }

    return SafeArea(
      child: Container(
        alignment: Alignment.topCenter,
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(3), topRight: Radius.circular(3))),
        child: Column(
          children: [
            buildDatabaseData(),

            ///--------talbe
            buildTableData(),

            ///column
            buildTableColumnData()
          ],
        ),
      ),
    );
  }

  ///build table data
  Widget buildTableData() {
    return Container(
      color: Colors.white,
      height: 90,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: List.generate(tableDatas.length, (index) {
                return GestureDetector(
                  onTap: () async {
                    _currentTableIndex = index;
                    await _updateTableSelect(tableDatas[index]);
                  },
                  child: Container(
                    width: tableDatas[index].tableName().length * 15,
                    margin: const EdgeInsets.all(5),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: _currentTableIndex == index
                            ? Colors.blueAccent
                            : Colors.white,
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 10,
                              color: Colors.black.withOpacity(0.1))
                        ]),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          tableDatas[index].tableName(),
                          style: TextStyle(
                              color: _currentTableIndex == index
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 16.6),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          SizedBox(
            height: 40,
            child: Container(
              height: 40,
              color: Colors.white,
              margin: const EdgeInsets.only(left: 10.0, top: 5),
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Tooltip(
                  message: 'view table information',
                  child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        var tableData = tableDatas[_currentTableIndex];
                        _showSimleDialog(
                            _fliterShowText(tableData.toJson().toString()));
                      },
                      child: const Icon(
                        Icons.info,
                        size: 30,
                      )),
                ),
                const SizedBox(
                  width: 15,
                ),
                DatabaseType.sqlite == currentDatabaseType ||
                        DatabaseType.sharedPreferences == currentDatabaseType
                    ? Tooltip(
                        message: "add item",
                        child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () async {
                              _addAnTableColumnData();
                            },
                            child: const Icon(
                              Icons.add,
                              size: 30,
                            )),
                      )
                    : Container()
              ]),
            ),
          ),
        ],
      ),
    );
  }

  ///add an table the column data
  ///this function currently only works for [sqlite] and [shared_preferences]
  _addAnTableColumnData() {
    var table = tableDatas[_currentTableIndex];

    if (DatabaseType.sqlite == currentDatabaseType) {
      var database =
          _databaseManager.databases[_currentDatabaseIndex] as SqliteDatabas;
      var std = table as SqliteTableData;
      Map<String, dynamic> data = {};
      var conditions = _databaseManager.sqliteHelper.updateMap[table.name];
      conditions ??= _databaseManager.sqliteHelper
          .updateMap[_databaseManager.sqliteHelper.defaultUpdateConditions];
      for (var column in std.columnData) {
        data[column.name] = '';
        if (conditions != null) {
          if (conditions.getUpdateNeedcolumnKey.contains(column.name)) {
            data[column.name] = column.type == 'integer'
                ? Random().nextInt(10000000)
                : Random().nextInt(10000000).toString();
          }
        }
      }
      database.db?.insert(table.tableName(), data);
      _updateTableSelect(table);
    } else if (DatabaseType.sharedPreferences == currentDatabaseType) {
      TextEditingController _key = TextEditingController();
      TextEditingController _value = TextEditingController();
      ColumnDataType selectType = ColumnDataType.string;
      _showOverlayEntry(SimpleDialog(
        title: const Text("创建数据"),
        children: [
          TextField(
            controller: _key,
            maxLines: 1,
            decoration: const InputDecoration(
                hintText: 'Key', contentPadding: EdgeInsets.only(left: 10)),
          ),
          TextField(
            controller: _value,
            maxLines: 1,
            decoration: const InputDecoration(
                hintText: 'Value', contentPadding: EdgeInsets.only(left: 10)),
          ),
          StatefulBuilder(builder: (context, setState) {
            return Wrap(
              children: [
                for (var type in ColumnDataType.values)
                  if (type == ColumnDataType.invalid)
                    Container()
                  else
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: ChoiceChip(
                        onSelected: (b) {
                          if (b) {
                            setState.call(() {
                              selectType = type;
                            });
                          }
                          // (context as Element).markNeedsBuild();
                          // print(b);
                        },
                        label: Text(
                          type.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        selected: selectType == type,
                        selectedColor: Colors.blue,
                        disabledColor: Colors.grey[500],
                      ),
                    )
              ],
            );
          }),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  onPressed: () async {
                    var b = await _databaseManager.sharedPreferencesHelper
                        .updateKey(selectType, _key.text, _value.text);
                    if (b) {
                      var tableData = tableDatas[_currentTableIndex]
                          as SharedPreferencesTableData;
                      //the data type need add, need use it update data
                      tableData.columnDataType[_key.text] = selectType;
                      _updateTableSelect(tableDatas[_currentTableIndex]);
                    }
                    _hideOverlayEntry();
                  },
                  child: const Text("创建")),
              ElevatedButton(
                  onPressed: () {
                    _hideOverlayEntry();
                  },
                  child: const Text("关闭")),
            ],
          )
        ],
      ));
    }
  }

  Widget buildDatabaseData() {
    return SizedBox(
      height: 88,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: List.generate(
                  _databaseManager.databases.length,
                  (index) => GestureDetector(
                        onTap: () {
                          _currentDatabaseIndex = index;
                          _updateDatabaseSelect(
                              _databaseManager.databases[index]);
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          margin: const EdgeInsets.all(5),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: _currentDatabaseIndex == index
                                  ? Colors.greenAccent
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(3),
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 10,
                                    color: Colors.black.withOpacity(0.1))
                              ]),
                          child: Stack(
                            children: [
                              Text(
                                _databaseManager.databases[index].databaseName,
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 16.6),
                              )
                            ],
                          ),
                        ),
                      )),
            ),
          ),
          const Divider(
            color: Colors.black,
            height: 0.2,
          )
        ],
      ),
    );
  }

  ///builder table column data
  Widget buildTableColumnData() {
    return Expanded(
      child: Builder(builder: (context) {
        List<CloumnData> columns = [];
        //if is null to use defalut update conditions
        UpdateConditions? updateConditions;
        var tableData = tableDatas[_currentTableIndex];
        if (currentDatabaseType == DatabaseType.sqlite) {
          var std = tableData as SqliteTableData;
          columns = std.columnData;
          if (columns.isEmpty) {
            return const Center(
              child: Text("没有数据"),
            );
          }
          updateConditions =
              _databaseManager.sqliteHelper.updateMap[tableData.tableName()];
          updateConditions ??= _databaseManager.sqliteHelper
              .updateMap[_databaseManager.sqliteHelper.defaultUpdateConditions];
        } else if (currentDatabaseType == DatabaseType.hive) {
          var thd = tableData as HiveTableData;
          var values = thd.box.values;
          if (values.isNotEmpty) {
            var keys = values.first.toJson().keys;
            for (var key in keys) {
              columns.add(HiveColumnData(name: key));
            }
          }
        } else if (currentDatabaseType == DatabaseType.sharedPreferences) {
          var sptd = tableData as SharedPreferencesTableData;
          updateConditions = SharedPreferencesUpdateConditions();
          columns.addAll(sptd.columns);
        }
        return columns.isEmpty
            ? const Center(
                child: Text("not data"),
              )
            : Padding(
                padding: const EdgeInsets.all(16),
                child: DataTable2(
                  columnSpacing: 15,
                  horizontalMargin: 5,
                  minWidth: columns.length * 100,
                  columns: List.generate(columns.length, (index) {
                    return DataColumn2(
                      label: Text(columns[index].columnName()),
                      size: ColumnSize.S,
                    );
                  }),
                  rows: List<DataRow>.generate(
                    datas.length,
                    (index) {
                      return DataRow(
                        cells: List.generate(columns.length, (cIndex) {
                          String data = "";
                          if (currentDatabaseType == DatabaseType.sqlite ||
                              currentDatabaseType == DatabaseType.hive) {
                            data = datas[index][columns[cIndex].columnName()]
                                .toString();
                          } else if (currentDatabaseType ==
                              DatabaseType.sharedPreferences) {
                            if (cIndex == 0) {
                              data = datas[index].keys.first;
                            } else {
                              data = datas[index].values.first.toString();
                            }
                          }
                          return DataCell(tableData is HiveTableData
                              ? Text(data)
                              : TextField(
                                  enabled: _enabledTextFiled(updateConditions!,
                                      columns[cIndex].columnName()),
                                  keyboardType:
                                      _checkTextInputType(tableData, cIndex),
                                  onChanged: (text) {
                                    if (currentDatabaseType ==
                                        DatabaseType.sqlite) {
                                      var map = _sqliteUpdateColumnData(
                                          map: datas[index],
                                          column: columns[cIndex].columnName(),
                                          writeText: text,
                                          updateConditions: updateConditions!,
                                          tableName: tableData.tableName());
                                      datas[index] = map;
                                    }
                                  },
                                  onSubmitted: (text) async {
                                    //---------
                                    if (currentDatabaseType ==
                                        DatabaseType.sharedPreferences) {
                                      var sptd = tableData
                                          as SharedPreferencesTableData;
                                      //take current key get column data type
                                      var columnType = sptd.columnDataType[
                                          datas[index].keys.first];
                                      assert(columnType != null,
                                          "column data type not can is null,check sharedPreferences table column data type  is right");
                                      _sharedPreferncesDataUpdate(columnType!,
                                          datas[index].keys.first, text);
                                    }
                                    _updateTableSelect(tableData);
                                  },
                                  controller: TextEditingController()
                                    ..text = data == 'null' ? '' : data,
                                ));
                        }),
                      );
                    },
                  ),
                ),
              );
      }),
    );
  }

  ///if column  constains at  SqliteUpdateConditions need column keys
  ///the column will not edit
  bool _enabledTextFiled(UpdateConditions conditions, String column) {
    if (conditions is SqliteUpdateConditions) {
      return !conditions.getUpdateNeedcolumnKey.contains(column);
    } else if (currentDatabaseType == DatabaseType.sharedPreferences) {
      return column != 'key';
    }
    return true;
  }

  /// if column filed type,pop up the correct keyboard
  TextInputType _checkTextInputType(TableData tableData, int index) {
    if (tableData is SqliteTableData) {
      var d = tableData.columnData[index].type;
      if (d == "integer") {
        return TextInputType.number;
      }
    } else if (tableData is SharedPreferencesTableData) {}
    return TextInputType.text;
  }

  Future<bool> _sharedPreferncesDataUpdate(
      ColumnDataType columnDataType, String key, Object value) async {
    return _databaseManager.sharedPreferencesHelper
        .updateKey(columnDataType, key, value);
  }

  ///update sqlite column data
  Map<String, dynamic> _sqliteUpdateColumnData(
      {required Map<String, dynamic> map,
      required String column,
      required String writeText,
      required UpdateConditions updateConditions,
      required String tableName}) {
    ///onlyRead Map convert can write
    var data = Map<String, dynamic>.from(map);
    //changage the column data
    data[column] = writeText;

    ///some conditions
    List<String> args = [];
    for (var column in updateConditions.getUpdateNeedcolumnKey!) {
      if (data[column] != null) {
        args.add(data[column].toString());
      }
    }
    _databaseManager.sqliteHelper.updateData(tableName,
        updateMaps: [data],
        where: updateConditions.getUpdateNeedWhere,
        whereArgs: args);
    return data;
  }

  //builder list widget
  Widget buildList() {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(6),
          sliver: SliverFixedExtentList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return AnimatedScale(
                scale: 100,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: AnimatedDefaultTextStyle(
                      child: Text(
                        _databaseManager.databases[index].databaseName,
                      ),
                      style: const TextStyle(fontSize: 50, color: Colors.black),
                      duration: const Duration(milliseconds: 300)),
                ),
              );
            }, childCount: _databaseManager.databases.length),
            itemExtent: 300,
          ),
        ),
      ],
    );
  }
}
