class Transaction {
  int timestamp;
  double credit;
  double value;
  String description;

  Transaction({this.timestamp, this.credit, this.value, this.description});

  factory Transaction.fromMap(Map<String, dynamic> transaction) {
    return Transaction(
      timestamp: transaction['timestamp'],
      credit: transaction['credit'],
      value: transaction['value'],
      description: transaction['description'],
    );
  }

  Map<String, dynamic> toMap() => {
        'timestamp': timestamp,
        'credit': credit,
        'value': value,
        'description': description
      };

  @override
  String toString() => toMap().toString();
}
