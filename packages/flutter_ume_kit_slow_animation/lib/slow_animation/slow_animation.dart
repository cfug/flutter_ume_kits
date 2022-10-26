import 'dart:convert';

import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ume/core/pluggable.dart';

import 'icon.dart' as icon;

class SlowAnimation extends StatefulWidget implements Pluggable {
  const SlowAnimation({Key? key}) : super(key: key);

  @override
  State<SlowAnimation> createState() => _SlowAnimationState();

  @override
  ImageProvider<Object> get iconImageProvider =>
      MemoryImage(base64Decode(icon.iconData));

  @override
  String get name => 'SlowAnimation';

  @override
  String get displayName => 'SlowAnimation';

  @override
  void onTrigger() {}

  @override
  Widget buildWidget(BuildContext? context) => this;
}

class _SlowAnimationState extends State<SlowAnimation>
    with SingleTickerProviderStateMixin {
  double _animationFactor = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    _animationFactor = timeDilation;

    _animationController =
        AnimationController(duration: const Duration(seconds: 1), vsync: this)
          ..forward()
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _animationController.repeat();
            }
          });

    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_animationController);

    WidgetsBinding.instance
        ?.addPostFrameCallback((_) => _animationController.forward());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black87,
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          RotationTransition(
              alignment: Alignment.center,
              turns: _animation,
              child: const FlutterLogo(
                size: 100,
              )),
          Slider(
            max: 10,
            min: 0.2,
            value: _animationFactor,
            onChanged: (value) {
              setState(() {
                _animationFactor = value;
              });
              timeDilation = value;
            },
          ),
          Text(
            '${(1.0 / _animationFactor).toStringAsFixed(2)} x',
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _animationFactor = 1;
              });
              timeDilation = 1;
            },
            icon: const Icon(Icons.rotate_left),
            label: const Text('Reset'),
          )
        ]));
  }
}
