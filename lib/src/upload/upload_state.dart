import '../common.dart';
import '../exceptions.dart';
import '../models/dispatcher_task.dart';

class UploadState extends ResultState<List<DispatcherTask>> {
  UploadState({
    List<DispatcherTask> queue,
    ApiException error,
    bool isInit = false,
    bool isBusy = false,
    bool isResult = false,
    bool isException = false,
  }) : super(
          value: queue,
          error: error,
          isInit: isInit,
          isBusy: isBusy,
          isResult: isResult,
          isException: isException,
        );

  factory UploadState.init() => UploadState(isInit: true);

  factory UploadState.busy() => UploadState(isBusy: true);

  factory UploadState.result(List<DispatcherTask> queue) =>
      UploadState(isResult: true, queue: queue);

  factory UploadState.exception(ApiException e) =>
      UploadState(isException: true, error: e);

  Map<String, dynamic> toMap() => {
        'queue': (value != null) ? value : 'null',
        'error': (error != null) ? error : 'null',
        'isInit': isInit,
        'isBusy': isBusy,
        'isResult': isResult,
        'isException': isException
      };

  @override
  String toString() => toMap().toString();
}
