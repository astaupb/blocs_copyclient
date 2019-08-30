import 'dart:async';
@TestOn("vm")
import 'dart:io';

import 'package:blocs_copyclient/pdf_creation.dart';
import 'package:image/image.dart';
import 'package:logging/logging.dart';
import 'package:pdf/widgets.dart';

import "package:test/test.dart";

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  PdfCreationBloc bloc;

  setUpAll(() {
    // create output directory for tests
    final Directory outDir = Directory('test/out');
    if (!(outDir.existsSync())) outDir.create();
  });

  test('create pdf file from lorem ipsum and save it to testdir', () {
    bloc = PdfCreationBloc();

    // read test text from file
    final File lorem = File('test/in/loremipsum.txt');
    final String loremIpsum = lorem.readAsStringSync();

    // start a listener that saves the result document in test folder
    StreamSubscription listener;
    listener = bloc.state.listen(
      expectAsync1((PdfCreationState state) {
        if (state.isResult) {
          final File file = File('test/out/lorem.pdf');
          file.createSync(recursive: true);
          file.writeAsBytesSync(state.value, flush: true);

          listener.cancel();
          bloc.dispose();
        }
      }, count: 3),
    );

    bloc.onCreateFromText(loremIpsum);
  });

  test('create pdf file from asta logo and save it to testdir', () {
    bloc = PdfCreationBloc();

    // start a listener that saves the result document in test folder
    StreamSubscription listener;
    listener = bloc.state.listen(
      expectAsync1((PdfCreationState state) {
        if (state.isResult) {
          final File file = File('test/out/image.pdf');
          file.createSync(recursive: true);
          file.writeAsBytesSync(state.value, flush: true);

          listener.cancel();
          bloc.dispose();
        }
      }, count: 3),
    );

    bloc.onCreateFromImage(
        decodeImage(File('test/in/asta.jpg').readAsBytesSync()),
        orientation: PageOrientation.landscape);
  });
}
