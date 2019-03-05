import '../models/pdf_file.dart';
import '../common.dart';
import '../../exceptions.dart';

class PdfState extends ResultState<List<PdfFile>> {
  PdfState({
    List<PdfFile> pdfs,
    ApiException error,
    bool isInit = false,
    bool isBusy = false,
    bool isResult = false,
    bool isException = false,
  }) : super(
          value: pdfs,
          error: error,
          isInit: isInit,
          isBusy: isBusy,
          isResult: isResult,
          isException: isException,
        );

  factory PdfState.init() => PdfState(isInit: true);

  factory PdfState.busy() => PdfState(isBusy: true);

  factory PdfState.result(List<PdfFile> result) =>
      PdfState(isResult: true, pdfs: result);

  factory PdfState.exception(ApiException e) =>
      PdfState(isException: true, error: e);

  Map<String, dynamic> toMap() => {
        'isInit': isInit,
        'isBusy': isBusy,
        'isResult': isResult,
        'isException': isException,
        'pdfs': (value != null) ? value : 'null',
        'error': (error != null) ? error : 'null',
      };

  @override
  String toString() => toMap().toString();
}
