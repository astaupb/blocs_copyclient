import 'package:meta/meta.dart';

import '../models/transaction.dart';
import '../common.dart';

class JournalState extends ResultState<JournalResult> {
  final JournalResult result;
  final String error;

  final bool isInit;
  final bool isBusy;
  final bool isResult;
  final bool isError;

  JournalState({
    this.result,
    this.error,
    this.isInit = false,
    this.isBusy = false,
    this.isResult = false,
    this.isError = false,
  });

  factory JournalState.init() => JournalState(isInit: true);

  factory JournalState.busy() => JournalState(isBusy: true);

  factory JournalState.result(JournalResult result) =>
      JournalState(isResult: true, result: result);

  factory JournalState.error(String e) => JournalState(isError: true, error: e);

  Map<String, dynamic> toMap() => {
        'result': (result != null) ? result : 'null',
        'error': (error != null) ? error : 'null',
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
