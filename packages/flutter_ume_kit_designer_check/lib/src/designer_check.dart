import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_ume/core/pluggable.dart';
import 'package:flutter_ume/core/ui/global.dart';
import 'package:image_picker/image_picker.dart';

import 'icon.dart' as icon;

class DesignerCheck extends StatefulWidget implements Pluggable {
  const DesignerCheck({Key? key}) : super(key: key);

  @override
  State<DesignerCheck> createState() => _DesignerCheckState();

  @override
  ImageProvider<Object> get iconImageProvider =>
      MemoryImage(base64Decode(icon.iconData));

  @override
  String get name => 'DesignerCheck';

  @override
  String get displayName => 'DesignerCheck';

  @override
  void onTrigger() {}

  @override
  Widget buildWidget(BuildContext? context) => this;
}

class _DesignerCheckState extends State<DesignerCheck> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: FutureBuilder(
        future: ImagePicker().pickImage(source: ImageSource.gallery),
        initialData: null,
        builder: (BuildContext context, AsyncSnapshot snapshot0) {
          if (snapshot0.hasData) {
            final path = (snapshot0.data as XFile).path;
            return FutureBuilder(
              future: captureImage(),
              initialData: null,
              builder: (BuildContext context, AsyncSnapshot snapshot1) {
                return snapshot1.hasData
                    ? DesignerCheckBoard(
                        backgroundImage: Image.memory(Uint8List.view(
                            (snapshot1.data as ByteData).buffer)),
                        foregroundImage: Image.file(File(path)))
                    : Container(
                        color: Colors.transparent,
                      );
              },
            );
          }
          return const SizedBox(
            height: 0,
            width: 0,
          );
        },
      ),
    );
  }

  Future<ByteData?> captureImage() async {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final boundary =
        rootKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final pngData = await image.toByteData(format: ui.ImageByteFormat.png);
    return pngData;
  }
}

class DesignerCheckBoard extends StatefulWidget {
  const DesignerCheckBoard(
      {Key? key, required this.backgroundImage, required this.foregroundImage})
      : super(key: key);

  final Image backgroundImage;
  final Image foregroundImage;

  @override
  State<DesignerCheckBoard> createState() => DesignerCheckBoardState();
}

class DesignerCheckBoardState extends State<DesignerCheckBoard> {
  double _opacityValue = 1;
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      InteractiveViewer.builder(
        builder: (ctx, quad) {
          return Stack(
            children: [
              widget.backgroundImage,
              Opacity(
                opacity: _opacityValue,
                child: widget.foregroundImage,
              ),
            ],
          );
        },
        minScale: 0.01,
        maxScale: 10,
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Row(
                  children: const [Text('Actual'), Text('Design')],
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ),
              ),
              SizedBox(
                height: 22,
                child: Slider(
                    value: _opacityValue,
                    onChanged: (value) =>
                        setState(() => _opacityValue = value)),
              ),
            ],
          ),
        ),
      )
    ]);
  }
}
