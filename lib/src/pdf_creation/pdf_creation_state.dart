import '../../exceptions.dart';
import '../common.dart';

class PdfCreationState extends ResultState<List<int>> {
  PdfCreationState({
    List<int> pdf,
    ApiException error,
    bool isInit = false,
    bool isBusy = false,
    bool isResult = false,
    bool isException = false,
  }) : super(
          value: pdf,
          error: error,
          isInit: isInit,
          isBusy: isBusy,
          isResult: isResult,
          isException: isException,
        );

  factory PdfCreationState.busy() => PdfCreationState(isBusy: true);

  factory PdfCreationState.exception(ApiException e) =>
      PdfCreationState(isException: true, error: e);

  factory PdfCreationState.init() => PdfCreationState(isInit: true);

  factory PdfCreationState.result(List<int> result) =>
      PdfCreationState(isResult: true, pdf: result);

  Map<String, dynamic> toMap() => {
        'isInit': isInit,
        'isBusy': isBusy,
        'isResult': isResult,
        'isException': isException,
        'pdf': (value != null) ? value.length : 'null',
        'error': (error != null) ? error : 'null',
      };

  @override
  String toString() => toMap().toString();
}
