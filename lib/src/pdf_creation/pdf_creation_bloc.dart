import 'dart:async';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:csv/csv.dart';
import 'package:image/image.dart' as img;
import 'package:logging/logging.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import '../../fonts/LiberationMono.dart';
import '../../fonts/LiberationSans.dart';
import 'pdf_creation_events.dart';
import 'pdf_creation_state.dart';

class PdfCreationBloc extends Bloc<PdfCreationEvent, PdfCreationState> {
  Logger _log = Logger('PdfCreationBloc');

  PdfCreationBloc() {
    _log.fine('$this started');
  }

  @override
  PdfCreationState get initialState => PdfCreationState.init();

  @override
  Stream<PdfCreationState> mapEventToState(
    PdfCreationEvent event,
  ) async* {
    yield PdfCreationState.busy();

    if (event is CreateFromText) {
      yield PdfCreationState.result((await _createFromText(
              event.text,
              event.showPageCount,
              event.center,
              event.orientation,
              event.monospace))
          .save());
    } else if (event is CreateFromImage) {
      yield PdfCreationState.result(
          (await _createFromImage(event.image, event.center, event.orientation))
              .save());
    } else if (event is CreateFromCsv) {
      yield PdfCreationState.result(_createFromCsv(
              event.csv,
              event.header,
              event.titles,
              event.showPageCount,
              event.center,
              event.orientation)
          .save());
    }
  }

  void onCreateFromCsv(
    String csv, {
    String header = '',
    List<String> titles = const [],
    bool showPageCount = false,
    bool center = false,
    PageOrientation orientation = PageOrientation.natural,
  }) =>
      this.add(CreateFromCsv(
          csv, header, titles, showPageCount, center, orientation));

  void onCreateFromImage(
    List<int> image, {
    bool center = true,
    PageOrientation orientation = PageOrientation.natural,
  }) =>
      this.add(CreateFromImage(image, center, orientation));

  void onCreateFromText(
    String text, {
    bool showPageCount = false,
    bool center = false,
    PageOrientation orientation = PageOrientation.natural,
    bool monospace = false,
  }) =>
      this.add(
          CreateFromText(text, showPageCount, center, orientation, monospace));

  @override
  void onError(Object error, StackTrace stacktrace) {
    _log.severe('Error: $error');
    _log.severe('Stacktrace: \n$stacktrace');
    super.onError(error, stacktrace);
  }

  @override
  void onEvent(PdfCreationEvent event) {
    _log.finer('Event: $event');
    super.onEvent(event);
  }

  @override
  void onTransition(Transition<PdfCreationEvent, PdfCreationState> transition) {
    _log.finer('State: ${transition.nextState}');
    super.onTransition(transition);
  }

  Document _createFromCsv(String csv, String header, List<String> titles,
      bool showPageCount, bool center, PageOrientation orientation) {
    final Document doc = Document();

    final List<List<dynamic>> csvList = CsvToListConverter()
        .convert(csv)
        .map((List<dynamic> item) => item.map(
              (subitem) {
                if (subitem != 'null') {
                  if (subitem is double) {
                    return subitem.toStringAsFixed(2);
                  } else {
                    return subitem.toString();
                  }
                } else {
                  return '';
                }
              },
            ).toList())
        .toList();

    doc.addPage(
      MultiPage(
        pageFormat: PdfPageFormat.a4,
        orientation: orientation,
        crossAxisAlignment:
            (center) ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        footer: (Context context) {
          if (showPageCount) {
            return _pageCountFooter(context);
          } else {
            return Container();
          }
        },
        build: (Context context) => [
          Header(level: 1, text: header),
          Table.fromTextArray(
            context: context,
            data: [
              if (titles.isNotEmpty)
                titles
              else
                List.generate(csvList.first.length, (_) => ''),
              ...csvList,
            ],
          )
        ],
      ),
    );
    return doc;
  }

  Future<Document> _createFromImage(
      List<int> image, bool center, PageOrientation orientation) async {
    final pdf = Document();

    // wait a few ms so the UI can receive the busy state in time
    await Future.delayed(const Duration(milliseconds: 100));

    _log.finest('decoding image');
    final img.Image imgImage = img.decodeImage(image);

    _log.finest('creating  pdf image');
    final PdfImage pdfImage = PdfImage(
      pdf.document,
      image: imgImage.getBytes(),
      width: imgImage.width,
      height: imgImage.height,
    );

    _log.finest('creating pdf with image');
    pdf.addPage(
      Page(
        pageFormat: PdfPageFormat.a4,
        orientation: (orientation == PageOrientation.natural)
            ? ((pdfImage.width > pdfImage.height)
                ? PageOrientation.landscape
                : PageOrientation.portrait)
            : orientation,
        build: (Context context) =>
            (center) ? Center(child: Image(pdfImage)) : Image(pdfImage),
      ),
    );

    _log.finest('image pdf done');
    return pdf;
  }

  Future<Document> _createFromText(String text, bool showPageCount, bool center,
      PageOrientation orientation, bool monospace) async {
    Font ttfSans;
    Font ttfMono;

    final Document doc = Document();
    final List<String> paragraphs = text.split('\n');

    if (!monospace) {
      final ByteData sansData = ByteData(liberationSans.length);
      for (int i = 0; i < liberationSans.length; i++) {
        sansData.setUint8(i, liberationSans[i]);
      }
      ttfSans = Font.ttf(sansData);
    } else {
      final ByteData monoData = ByteData(liberationMono.length);
      for (int i = 0; i < liberationMono.length; i++) {
        monoData.setUint8(i, liberationMono[i]);
      }
      ttfMono = Font.ttf(monoData);
    }

    doc.addPage(
      MultiPage(
        pageFormat: PdfPageFormat.a4,
        orientation: orientation,
        crossAxisAlignment:
            (center) ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        footer: (Context context) {
          if (showPageCount) {
            return _pageCountFooter(context);
          } else {
            return Container();
          }
        },
        build: (Context context) => [
          ...paragraphs.map((String paragraph) => Paragraph(
              text: paragraph,
              style: TextStyle(font: (monospace) ? ttfMono : ttfSans))),
        ],
      ),
    );
    return doc;
  }

  Widget _pageCountFooter(Context context) => Container(
      alignment: Alignment.centerRight,
      child: Text(context.pageNumber.toString(),
          style: Theme.of(context)
              .defaultTextStyle
              .copyWith(color: PdfColors.grey)));
}
