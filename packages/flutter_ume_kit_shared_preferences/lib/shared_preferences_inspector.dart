import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ume/flutter_ume.dart';
import 'icon_data.dart' as icon;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

extension BoolParsing on String {
  bool? tryParseBool() {
    if (this.toLowerCase() == 'true') {
      return true;
    }
    if (this.toLowerCase() == 'false') {
      return false;
    }
    return null;
  }
}

class SharedPreferencesInspector extends StatefulWidget implements Pluggable {
  SharedPreferencesInspector({Key? key}) : super(key: key);

  @override
  State<SharedPreferencesInspector> createState() =>
      _SharedPreferencesInstpectorState();

  @override
  Widget buildWidget(BuildContext? context) {
    return this;
  }

  @override
  String get displayName => 'SharedPreferencesInfo';

  @override
  ImageProvider<Object> get iconImageProvider =>
      MemoryImage(base64Decode(icon.iconData));

  @override
  String get name => 'SharedPreferencesInfo';

  @override
  void onTrigger() {}
}

class SharePreferencesModel {
  late String key;
  Object? value;

  SharePreferencesModel({required this.key, this.value});
}

class _SharedPreferencesInstpectorState
    extends State<SharedPreferencesInspector> {
  var sharePreferencesList = <SharePreferencesModel>[];
  SharePreferencesModel? selectModel;
  @override
  void initState() {
    super.initState();
    loadSharedPreferencesData();
  }

  void loadSharedPreferencesData() {
    SharedPreferences.getInstance().then((value) => setState(() {
          var keys = value.getKeys();
          sharePreferencesList = [];
          for (var key in keys) {
            sharePreferencesList
                .add(SharePreferencesModel(key: key, value: value.get(key)));
          }
        }));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text('SharedPreferencesInfo'),
          ),
          body: Stack(
            children: [
              ListView.separated(
                  itemBuilder: (ctx, index) {
                    var model = sharePreferencesList[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectModel = model;
                        });
                      },
                      child: ListTile(
                        title: Text('${model.key}'),
                        trailing: Icon(Icons.arrow_forward_ios),
                      ),
                    );
                  },
                  separatorBuilder: (ctx, index) => Divider(),
                  itemCount: sharePreferencesList.length),
              Visibility(
                  child: selectModel != null
                      ? SharedPreferencesItemCell(
                          model: selectModel!,
                          onRefresh: () {
                            setState(() {
                              selectModel = null;
                              loadSharedPreferencesData();
                            });
                          },
                          onCancel: () {
                            setState(() {
                              selectModel = null;
                            });
                          },
                        )
                      : Container(),
                  visible: selectModel != null),
            ],
          )),
    );
  }
}

class SharedPreferencesItemCell extends StatefulWidget {
  final SharePreferencesModel model;
  final VoidCallback? onCancel;
  final VoidCallback? onRefresh;

  SharedPreferencesItemCell(
      {Key? key, required this.model, this.onCancel, this.onRefresh})
      : super(key: key);

  @override
  State<SharedPreferencesItemCell> createState() =>
      _SharedPreferencesItemCellState();
}

class _SharedPreferencesItemCellState extends State<SharedPreferencesItemCell> {
  final TextEditingController controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    controller.text = widget.model.value.toString();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Padding(
        padding: EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Key: ${widget.model.key}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              ),
              SizedBox(height: 15),
              Text(
                'Runtimetype: ${widget.model.value.runtimeType}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              ),
              SizedBox(height: 15),
              Container(
                child: TextField(
                  maxLines: 10,
                  focusNode: _focusNode,
                  controller: controller,
                  decoration: InputDecoration(
                    // border: InputBorder.none,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Center(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(CupertinoColors.systemGrey),
                    ),
                    onPressed: () {
                      widget.onCancel?.call();
                    },
                    child: Text(
                      '返回',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 15),
                  TextButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(CupertinoColors.systemGrey),
                    ),
                    onPressed: () async {
                      var share = await SharedPreferences.getInstance();
                      await share.remove(widget.model.key);
                      widget.onRefresh?.call();
                    },
                    child: Text(
                      '删除',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 15),
                  TextButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(CupertinoColors.systemGrey),
                    ),
                    onPressed: () async {
                      var value = await SharedPreferences.getInstance();
                      if (widget.model.value.runtimeType == double) {
                        if (double.tryParse(controller.text) != null) {
                          await value.setDouble(widget.model.key,
                              double.tryParse(controller.text)!);
                        } else {
                          print("${controller.text} can not parse to double");
                        }
                      } else if (widget.model.value.runtimeType == int) {
                        if (int.tryParse(controller.text) != null) {
                          await value.setInt(
                              widget.model.key, int.parse(controller.text));
                        } else {
                          print("${controller.text} can not parse to int");
                        }
                      } else if (widget.model.value.runtimeType == bool) {
                        if (controller.text.tryParseBool() != null) {
                          await value.setBool(widget.model.key,
                              controller.text.tryParseBool()!);
                        } else {
                          print("${controller.text} can not parse to bool");
                        }
                      } else if (widget.model.value.runtimeType == String) {
                        await value.setString(
                            widget.model.key, controller.text);
                      } else if (widget.model.value.runtimeType.toString() ==
                          "List<String>") {
                        var data = controller.text.replaceFirst('[', '');
                        data = data.replaceFirst(']', '');
                        var list = data.split(',');
                        var listData = <String>[];
                        list.forEach((element) {
                          listData.add(element.trim());
                        });
                        print("list is $listData");
                        await value.setStringList(widget.model.key, listData);
                      }
                      widget.onRefresh?.call();
                    },
                    child: Text(
                      '保存',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.white),
                    ),
                  ),
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }
}
