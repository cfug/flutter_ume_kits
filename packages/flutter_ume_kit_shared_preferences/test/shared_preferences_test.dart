// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ume_kit_shared_preferences/flutter_ume_kit_shared_preferences.dart';
import 'mock_classes.dart';
import 'package:flutter_ume/core/ui/global.dart';

void main() {
  group('ConsolePanel', () {
    test('Pluggable', () {
      final pluggable = SharedPreferencesInspector();
      final Widget widget = pluggable.buildWidget(MockContext());
      final String name = pluggable.name;
      final VoidCallback onTrigger = pluggable.onTrigger..call();
      final ImageProvider imageProvider = pluggable.iconImageProvider;

      expect(widget, isA<Widget>());
      expect(name, isNotEmpty);
      expect(onTrigger, isA<Function>());
      expect(imageProvider, isNotNull);
    });

    testWidgets('SharedPreference pump widget', (tester) async {
      WidgetsFlutterBinding.ensureInitialized();

      await tester.pumpWidget(MaterialApp(
          key: rootKey,
          home: Scaffold(
            body: Container(),
          )));
      await tester.pump(Duration(seconds: 1));
      await tester.pumpAndSettle();

      final showCode = SharedPreferencesInspector();

      await tester.pumpWidget(MaterialApp(
          key: rootKey,
          home: Scaffold(
            body: showCode,
          )));
      await tester.pump(Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(showCode, isNotNull);
    });
  });
}
