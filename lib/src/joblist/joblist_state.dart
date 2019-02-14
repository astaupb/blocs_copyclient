import '../models/job.dart';
import '../common.dart';
import '../../exceptions.dart';

class JoblistState extends ResultState<List<Job>> {
  JoblistState({
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

  factory JoblistState.init() => JoblistState(isInit: true);

  factory JoblistState.busy() => JoblistState(isBusy: true);

  factory JoblistState.exception(ApiException e) =>
      JoblistState(isException: true, error: e);

  factory JoblistState.result(List<Job> list) =>
      JoblistState(isResult: true, jobs: list);

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
