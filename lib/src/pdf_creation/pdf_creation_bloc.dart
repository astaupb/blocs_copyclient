import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:csv/csv.dart';
import 'package:image/image.dart' as img;
import 'package:logging/logging.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

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
  void dispose() {
    _log.fine('disposing of $this');
    super.dispose();
  }

  @override
  Stream<PdfCreationState> mapEventToState(
    PdfCreationEvent event,
  ) async* {
    yield PdfCreationState.busy();

    if (event is CreateFromText) {
      yield PdfCreationState.result(_createFromText(
              event.text, event.showPageCount, event.center, event.orientation)
          .save());
    } else if (event is CreateFromImage) {
      yield PdfCreationState.result(
          _createFromImage(event.image, event.center, event.orientation)
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

  void onCreateFromCsv(String csv,
          {String header = '',
          List<String> titles = const [],
          bool showPageCount = false,
          bool center = false,
          PageOrientation orientation = PageOrientation.natural}) =>
      dispatch(CreateFromCsv(
          csv, header, titles, showPageCount, center, orientation));

  void onCreateFromImage(img.Image image,
          {bool center = true,
          PageOrientation orientation = PageOrientation.natural}) =>
      dispatch(CreateFromImage(image, center, orientation));

  void onCreateFromText(String text,
          {bool showPageCount = false,
          bool center = false,
          PageOrientation orientation = PageOrientation.natural}) =>
      dispatch(CreateFromText(text, showPageCount, center, orientation));

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
        .map((List<dynamic> item) => item
            .map((subitem) => (subitem != 'null') ? subitem.toString() : '')
            .toList())
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

  Document _createFromImage(
      img.Image image, bool center, PageOrientation orientation) {
    final pdf = Document();

    final PdfImage pdfImage = PdfImage(
      pdf.document,
      image: image.getBytes(),
      width: image.width,
      height: image.height,
    );

    pdf.addPage(
      Page(
        pageFormat: PdfPageFormat.a4,
        orientation: orientation,
        build: (Context context) =>
            (center) ? Center(child: Image(pdfImage)) : Image(pdfImage),
      ),
    );
    return pdf;
  }

  Document _createFromText(String text, bool showPageCount, bool center,
      PageOrientation orientation) {
    final Document doc = Document();
    final List<String> paragraphs = text.split('\n');

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
          ...paragraphs.map((String paragraph) => Paragraph(text: paragraph)),
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
