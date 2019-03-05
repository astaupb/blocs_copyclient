abstract class PdfEvent {}

class GetPdf extends PdfEvent {
  final int id;

  GetPdf(this.id);

  Map<String, dynamic> toMap() => {'id': id};

  @override
  String toString() => toMap().toString();
}

class InitPdf extends PdfEvent {
  final String token;

  InitPdf(this.token);

  Map<String, dynamic> toMap() => {
        'token': token,
      };

  @override
  String toString() => toMap().toString();
}
