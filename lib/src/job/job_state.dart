import '../models/job.dart';
import '../common.dart';
import '../exceptions.dart';

class JobState extends ResultState<Job> {
  JobState({
    Job job,
    ApiException error,
    bool isInit = false,
    bool isBusy = false,
    bool isResult = false,
    bool isException = false,
  }) : super(
          value: job,
          error: error,
          isInit: isInit,
          isBusy: isBusy,
          isResult: isResult,
          isException: isException,
        );

  factory JobState.init() => JobState(isInit: true);

  factory JobState.busy() => JobState(isBusy: true);

  factory JobState.result(Job result) => JobState(isResult: true, job: result);

  factory JobState.exception(ApiException e) =>
      JobState(isException: true, error: e);

  Map<String, dynamic> toMap() => {
        'isInit': isInit,
        'isBusy': isBusy,
        'isResult': isResult,
        'isException': isException,
        'job': (value != null) ? value : 'null',
        'error': (error != null) ? error : 'null',
      };

  @override
  String toString() => toMap().toString();
}
