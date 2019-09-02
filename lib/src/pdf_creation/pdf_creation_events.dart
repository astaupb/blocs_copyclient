import 'package:image/image.dart';
import 'package:pdf/widgets.dart' as pdf;

class CreateFromCsv extends PdfCreationEvent implements MultipageCreationEvent {
  final String csv;
  final String header;
  final List<String> titles;

  @override
  bool showPageCount;

  CreateFromCsv(this.csv, this.header, this.titles, this.showPageCount,
      bool center, pdf.PageOrientation orientation)
      : super(center, orientation);

  @override
  String toString() =>
      '[CreateFromCsv with titles: $titles "${csv.substring(0, 32)}"]';
}

class CreateFromImage extends PdfCreationEvent {
  final List<int> image;

  CreateFromImage(this.image, bool center, pdf.PageOrientation orientation)
      : super(center, orientation);

  @override
  String toString() =>
      '[CreateFromImage center:$center ${image.length}]';
}

class CreateFromText extends PdfCreationEvent
    implements MultipageCreationEvent {
  final String text;

  @override
  bool showPageCount;

  CreateFromText(this.text, this.showPageCount, bool center,
      pdf.PageOrientation orientation)
      : super(center, orientation);

  @override
  String toString() =>
      '[CreateFromText center:$center "${text.substring(0, 32)}[...]"]';
}

mixin MultipageCreationEvent {
  bool showPageCount;
}

abstract class PdfCreationEvent {
  final bool center;
  final pdf.PageOrientation orientation;

  PdfCreationEvent(this.center, this.orientation);
}
