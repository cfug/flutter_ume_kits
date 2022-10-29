library flutter_ume_kit_clean_local_data;

import 'dart:convert';

import 'package:flutter_ume_kit_clean_local_data/util.dart';
import 'package:data_size/data_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ume/flutter_ume.dart';
import 'package:flutter_ume/util/floating_widget.dart';

import 'icon.dart' as icon;

class DataCleanPanel extends StatefulWidget implements Pluggable {
  const DataCleanPanel({Key? key}) : super(key: key);

  @override
  State<DataCleanPanel> createState() => _DataCleanPanelState();

  @override
  Widget buildWidget(BuildContext? context) => this;

  @override
  String get displayName => 'DataClean';

  @override
  ImageProvider<Object> get iconImageProvider =>
      MemoryImage(base64Decode(icon.iconData));

  @override
  String get name => 'DataClean';

  @override
  void onTrigger() {}
}

class _DataCleanPanelState extends State<DataCleanPanel> {
  int cacheTotalSize = 0;

  @override
  void initState() {
    _getCacheTotalSize();
    super.initState();
  }

  void _getCacheTotalSize() {
    LocalDataUtil.total().then((value) {
      setState(() {
        cacheTotalSize = value;
      });
    });
  }

  void _cleanCache() async {
    await LocalDataUtil.clean();
    setState(() {
      cacheTotalSize = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FloatingWidget(
      contentWidget: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
                'Local Data Size: ${cacheTotalSize.formatByteSize(prefix: Prefix.binary)}'),
            const SizedBox(
              height: 16,
            ),
            TextButton(
              onPressed: _cleanCache,
              child: const Text('Clean Data'),
              style: TextButton.styleFrom(
                side: const BorderSide(color: Colors.blue, width: 1),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
