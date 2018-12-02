import '../models/job.dart';
import '../common.dart';
import '../exceptions.dart';

class JobsState extends ResultState<List<Job>> {
  JobsState({
    List<Job> jobs,
    ApiException error,
    bool isInit = false,
    bool isBusy = false,
    bool isException = false,
    bool isResult = false,
  }) : super(
          value: jobs,
          error: error,
          isInit: isInit,
          isBusy: isBusy,
          isResult: isResult,
          isException: isException,
        );

  factory JobsState.init() => JobsState(isInit: true);

  factory JobsState.busy() => JobsState(isBusy: true);

  factory JobsState.exception(ApiException e) => JobsState(isException: true, error: e);

  factory JobsState.result(List<Job> list) =>
      JobsState(isResult: true, jobs: list);

  Map<String, dynamic> toMap() => {
        'jobs': (value != null) ? value.length : 'null',
        'error': (error != null) ? error : 'null',
        'isInit': isInit,
        'isBusy': isBusy,
        'isResult': isResult,
        'isException': isException
      };

  @override
  String toString() => toMap().toString();
}
