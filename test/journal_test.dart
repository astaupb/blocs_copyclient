@TestOn("vm")
import 'dart:io';

import 'package:blocs_copyclient/journal.dart';
import 'package:logging/logging.dart';

import "package:test/test.dart";

import 'example_data.dart';

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  //JournalBloc bloc;

  setUpAll(() {
    // create output directory for tests
    final Directory outDir = Directory('./out');
    if (!(outDir.existsSync())) outDir.create();
  });

  group('csv creating tests', () {
    test('create csv string from journal', () {
      final String csv = journalToCsv(exampleJournal);
      print(csv);
    });

    test('create csv file', () {
      File file = File('./out/journal.csv')..createSync(recursive: true);
      file.writeAsBytesSync(journalToCsv(exampleJournal).codeUnits, flush: true);
    });
  });
}
