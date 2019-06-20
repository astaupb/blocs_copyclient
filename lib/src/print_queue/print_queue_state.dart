import '../models/print_queue_result.dart';
import '../common.dart';
import '../../exceptions.dart';

class PrintQueueState extends ResultState<PrintQueueResult> {
  bool isLocked;
  String lockUid;

  PrintQueueState({
    PrintQueueResult queue,
    ApiException error,
    bool isInit = false,
    bool isBusy = false,
    bool isException = false,
    bool isResult = false,
    this.isLocked = false,
    this.lockUid,
  }) : super(
          value: queue,
          error: error,
          isInit: isInit,
          isBusy: isBusy,
          isResult: isResult,
          isException: isException,
        );

  factory PrintQueueState.init() => PrintQueueState(isInit: true);

  factory PrintQueueState.busy() => PrintQueueState(isBusy: true);

  factory PrintQueueState.exception(ApiException e) => PrintQueueState(isException: true, error: e);

  factory PrintQueueState.result(PrintQueueResult queue) =>
      PrintQueueState(queue: queue, isResult: true);

  factory PrintQueueState.locked(String uid) => PrintQueueState(isLocked: true, lockUid: uid);
}
