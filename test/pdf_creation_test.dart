@TestOn("vm")
import 'dart:async';
import 'dart:io';

import 'package:blocs_copyclient/pdf_creation.dart';
import 'package:blocs_copyclient/src/journal/journal_bloc.dart';
import 'package:image/image.dart';
import 'package:logging/logging.dart';
import 'package:pdf/widgets.dart';
import "package:test/test.dart";

import 'example_data.dart';

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  PdfCreationBloc bloc;

  setUpAll(() {
    // create output directory for tests
    final Directory outDir = Directory('./out');
    if (!(outDir.existsSync())) outDir.create();
  });

  test('create pdf file from lorem ipsum and save it to testdir', () {
    bloc = PdfCreationBloc();

    // read test text from file
    final File lorem = File('./in/loremipsum.txt');
    final String loremIpsum = lorem.readAsStringSync();

    // start a listener that saves the result document in test folder
    StreamSubscription listener;
    listener = bloc.state.listen(
      expectAsync1((PdfCreationState state) {
        if (state.isResult) {
          final File file = File('./out/lorem.pdf');
          file.createSync(recursive: true);
          file.writeAsBytesSync(state.value, flush: true);

          listener.cancel();
          bloc.dispose();
        }
      }, count: 3),
    );

    bloc.onCreateFromText(loremIpsum, showPageCount: true);
  });

  test('create pdf file from asta logo and save it to testdir', () {
    bloc = PdfCreationBloc();

    // start a listener that saves the result document in test folder
    StreamSubscription listener;
    listener = bloc.state.listen(
      expectAsync1((PdfCreationState state) {
        if (state.isResult) {
          final File file = File('./out/image.pdf');
          file.createSync(recursive: true);
          file.writeAsBytesSync(state.value, flush: true);

          listener.cancel();
          bloc.dispose();
        }
      }, count: 3),
    );

    bloc.onCreateFromImage(
        decodeImage(File('./in/asta.jpg').readAsBytesSync()),
        orientation: PageOrientation.landscape);
  });

  test('create pdf file from journal csv and save it to testdir', () {
    bloc = PdfCreationBloc();

    String csvJournal = journalToCsv(exampleJournal);

    // start a listener that saves the result document in test folder
    StreamSubscription listener;
    listener = bloc.state.listen(
      expectAsync1((PdfCreationState state) {
        if (state.isResult) {
          final File file = File('./out/journal.pdf');
          file.createSync(recursive: true);
          file.writeAsBytesSync(state.value, flush: true);

          listener.cancel();
          bloc.dispose();
        }
      }, count: 3),
    );

    bloc.onCreateFromCsv(csvJournal,
        header: 'Transaktionen seit ${exampleJournal.last.timestamp}',
        titles: ['Wert in Euro', 'Beschreibung', 'Zeit'],
        showPageCount: true);
  });
}
