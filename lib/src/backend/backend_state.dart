import '../models/backend.dart';
import '../common.dart';

class BackendState extends ResultState<Backend> {
  BackendState({
    Backend backend,
    String error,
    bool isInit = false,
    bool isResult = false,
    bool isError = false,
  }) : super(
          value: backend,
          err: error,
          isInit: isInit,
          isResult: isResult,
          isError: isError,
        );

  factory BackendState.init() => BackendState(isInit: true);

  factory BackendState.error(String e) => BackendState(isError: true, error: e);

  factory BackendState.result(Backend backend) =>
      BackendState(isResult: true, backend: backend);

  Map<String, dynamic> toMap() => {
        'isInit': isInit,
        'isResult': isResult,
        'isError': isError,
        'backend': (value != null) ? value.toMap() : {},
        'error': (err != null) ? err.toString() : 'null',
      };

  @override
  String toString() => toMap().toString();
}
