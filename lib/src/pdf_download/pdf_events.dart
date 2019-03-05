abstract class PdfEvent {}

class GetPdf extends PdfEvent {
  final String uid;

  GetPdf(this.uid);
}
