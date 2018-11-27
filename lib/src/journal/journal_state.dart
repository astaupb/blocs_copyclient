import 'package:meta/meta.dart';

import '../models/transaction.dart';
import '../common.dart';

class JournalState extends ResultState<JournalResult> {
  JournalState({
    JournalResult journalResult,
    String error,
    bool isInit = false,
    bool isBusy = false,
    bool isResult = false,
    bool isError = false,
  }) : super(
          value: journalResult,
          err: error,
          isInit: isInit,
          isBusy: isBusy,
          isResult: isResult,
          isError: isError,
        );

  factory JournalState.init() => JournalState(isInit: true);

  factory JournalState.busy() => JournalState(isBusy: true);

  factory JournalState.result(JournalResult result) =>
      JournalState(isResult: true, journalResult: result);

  factory JournalState.error(String e) => JournalState(isError: true, error: e);

  Map<String, dynamic> toMap() => {
        'result': (value != null) ? value : 'null',
        'error': (err != null) ? err : 'null',
        'isInit': isInit,
        'isBusy': isBusy,
        'isResult': isResult,
        'isError': isError
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
