import 'package:meta/meta.dart';

import '../models/transaction.dart';
import '../common.dart';
import '../exceptions.dart';

class JournalState extends ResultState<JournalResult> {
  JournalState({
    JournalResult journalResult,
    ApiException error,
    bool isInit = false,
    bool isBusy = false,
    bool isResult = false,
    bool isException = false,
  }) : super(
          value: journalResult,
          error: error,
          isInit: isInit,
          isBusy: isBusy,
          isResult: isResult,
          isException: isException,
        );

  factory JournalState.init() => JournalState(isInit: true);

  factory JournalState.busy() => JournalState(isBusy: true);

  factory JournalState.result(JournalResult result) =>
      JournalState(isResult: true, journalResult: result);

  factory JournalState.exception(ApiException e) => JournalState(isException: true, error: e);

  Map<String, dynamic> toMap() => {
        'result': (value != null) ? value : 'null',
        'error': (error != null) ? error : 'null',
        'isInit': isInit,
        'isBusy': isBusy,
        'isResult': isResult,
        'isException': isException
      };

  @override
  String toString() => toMap().toString();
}

class JournalResult {
  final double credit;
  final List<Transaction> transactions;

  JournalResult({@required this.credit, @required this.transactions});

  Map<String, dynamic> toMap() =>
      {'credit': credit, 'transactions': transactions.length};

  @override
  String toString() => toMap().toString();
}
