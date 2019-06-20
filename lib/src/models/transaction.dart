class Transaction {
  int value;
  String description;
  bool without_receipt;
  int admin_id;
  String timestamp;

  Transaction({this.value, this.description, this.without_receipt, this.admin_id, this.timestamp});

  factory Transaction.fromMap(Map<String, dynamic> transaction) {
    return Transaction(
      value: transaction['value'],
      description: transaction['description'],
      without_receipt: transaction['without_receipt'],
      admin_id: transaction['admin_id'],
      timestamp: transaction['timestamp'],
    );
  }

  Map<String, dynamic> toMap() => {
        'value': value,
        'description': description,
        'without_receipt': without_receipt,
        'admin_id': admin_id,
        'timestamp': timestamp,
      };

  @override
  String toString() => toMap().toString();
}
