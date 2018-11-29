import '../common.dart';
import '../models/dispatcher_task.dart';

class UploadState extends ResultState<List<DispatcherTask>> {
  UploadState({
    var queue,
    String error,
    bool isInit = false,
    bool isBusy = false,
    bool isResult = false,
    bool isError = false,
  }) : super(
          value: queue,
          err: error,
          isInit: isInit,
          isBusy: isBusy,
          isResult: isResult,
          isError: isError,
        );

  factory UploadState.init() => UploadState(isInit: true);

  factory UploadState.busy() => UploadState(isBusy: true);

  factory UploadState.result(List<DispatcherTask> queue) =>
      UploadState(isResult: true, queue: queue);

  factory UploadState.error(String e) => UploadState(isError: true, error: e);

  Map<String, dynamic> toMap() => {
        'queue': (value != null) ? value : 'null',
        'error': (err != null) ? err : 'null',
        'isInit': isInit,
        'isBusy': isBusy,
        'isResult': isResult,
        'isError': isError
      };

  @override
  String toString() => toMap().toString();
}
