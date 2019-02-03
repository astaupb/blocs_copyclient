import 'package:meta/meta.dart';
import '../models/transaction.dart';

class JournalResult {
  final int credit;
  final List<Transaction> transactions;

  JournalResult({@required this.credit, @required this.transactions});

  Map<String, dynamic> toMap() =>
      {'credit': credit, 'transactions': transactions.length};

  @override
  String toString() => toMap().toString();
}
