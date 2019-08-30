import 'package:image/image.dart';
import 'package:pdf/widgets.dart' as pdf;

class CreateFromImage extends PdfCreationEvent {
  final Image image;

  CreateFromImage(this.image, bool center, pdf.PageOrientation orientation)
      : super(center, orientation);

  @override
  String toString() =>
      '[CreateFromImage center:$center ${image.exif.data.toString()} ${image.width}x${image.height}]';
}

class CreateFromText extends PdfCreationEvent {
  final String text;

  CreateFromText(this.text, bool center, pdf.PageOrientation orientation)
      : super(center, orientation);

  @override
  String toString() =>
      '[CreateFromText center:$center "${text.substring(0, 32)}[...]"]';
}

abstract class PdfCreationEvent {
  final bool center;
  final pdf.PageOrientation orientation;

  PdfCreationEvent(this.center, this.orientation);
}
