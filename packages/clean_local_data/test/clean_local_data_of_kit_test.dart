import 'package:clean_local_data/clean_local_data.dart';
import 'package:clean_local_data/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ume/flutter_ume.dart';

import 'mock_classes.dart';

void main() {
  group('DataCleanPanel', () {
    test('Pluggable', () {
      const pluggable = DataCleanPanel();
      final widget = pluggable.buildWidget(MockContext());
      final name = pluggable.name;
      final onTrigger = pluggable.onTrigger;
      onTrigger();
      final imageProvider = pluggable.iconImageProvider;

      expect(widget, isA<Widget>());
      expect(name, isNotEmpty);
      expect(onTrigger, isA<Function>());
      expect(imageProvider, isNotNull);
    });

    testWidgets('DataCleanPanel pump widget, clean data', (tester) async {
      const panel = DataCleanPanel();

      await tester.pumpWidget(MaterialApp(
        key: rootKey,
        home: const Scaffold(
          body: panel,
        ),
      ));

      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(panel, isNotNull);

      await tester.tap(find.text('Clean Data'));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
    });
  });

  group('CacheUtil', () {
    test('total', () async {
      final total = await LocalDataUtil.total();
      expect(total, isNotNull);
    });

    test('clean', () async {
      await LocalDataUtil.clean();
      final total = await LocalDataUtil.total();
      expect(total, 0);
    });
  });
}
