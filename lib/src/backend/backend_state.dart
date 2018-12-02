import '../models/backend.dart';
import '../common.dart';
import '../exceptions.dart';

class BackendState extends ResultState<Backend> {
  BackendState({
    Backend backend,
    ApiException error,
    bool isInit = false,
    bool isResult = false,
    bool isException = false,
  }) : super(
          value: backend,
          error: error,
          isInit: isInit,
          isResult: isResult,
          isException: isException,
        );

  factory BackendState.init() => BackendState(isInit: true);

  factory BackendState.exception(ApiException e) =>
      BackendState(isException: true, error: e);

  factory BackendState.result(Backend backend) =>
      BackendState(isResult: true, backend: backend);

  Map<String, dynamic> toMap() => {
        'isInit': isInit,
        'isResult': isResult,
        'isException': isException,
        'backend': (value != null) ? value.toMap() : {},
        'error': (error != null) ? error.toString() : 'null',
      };

  @override
  String toString() => toMap().toString();
}
