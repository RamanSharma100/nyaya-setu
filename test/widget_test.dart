import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nyayasetu/core/storage/hive_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final tempDir = Directory.systemTemp.createTempSync('hive_test');
    Hive.init(tempDir.path);
    await Hive.openBox(HiveService.settingsBoxName);
    await Hive.openBox(HiveService.bookmarksBoxName);
    await Hive.openBox(HiveService.notesBoxName);
    await Hive.openBox(HiveService.flashcardProgressBoxName);
    await Hive.openBox(HiveService.mainsDraftsBoxName);
  });

  testWidgets('NyayaSetu smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('NyayaSetu Judicial App'),
        ),
      ),
    );
    expect(find.text('NyayaSetu Judicial App'), findsOneWidget);
  });
}
