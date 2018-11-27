import '../models/job.dart';
import '../common.dart';

class JobsState extends ResultState<List<Job>> {
  JobsState({
    List<Job> jobs,
    String error,
    bool isInit,
    bool isBusy,
    bool isError,
    bool isResult,
  }) : super(
          value: jobs,
          err: error,
          isInit: isInit,
          isBusy: isBusy,
          isResult: isResult,
          isError: isError,
        );

  factory JobsState.init() => JobsState(isInit: true);

  factory JobsState.busy() => JobsState(isBusy: true);

  factory JobsState.error(String e) => JobsState(isError: true, error: e);

  factory JobsState.result(List<Job> list) =>
      JobsState(isResult: true, jobs: list);

  Map<String, dynamic> toMap() => {
        'jobs': (value != null) ? value.length : 'null',
        'error': (err != null) ? err : 'null',
        'isInit': isInit,
        'isBusy': isBusy,
        'isResult': isResult,
        'isError': isError
      };

  @override
  String toString() => toMap().toString();
}
