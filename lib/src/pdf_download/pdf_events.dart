import '../models/backend.dart';

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
  final Backend backend;

  InitPdf(this.token, this.backend);

  Map<String, dynamic> toMap() => {
        'token': token,
        'backend': backend.toMap(),
      };

  @override
  String toString() => toMap().toString();
}
