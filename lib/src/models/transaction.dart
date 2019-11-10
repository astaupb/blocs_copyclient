class Transaction {
  int value;
  String description;
  bool withoutReceipt;
  int adminId;
  String timestamp;

  Transaction({this.value, this.description, this.withoutReceipt, this.adminId, this.timestamp});

  factory Transaction.fromMap(Map<String, dynamic> transaction) {
    return Transaction(
      value: transaction['value'],
      description: transaction['description'],
      withoutReceipt: transaction['without_receipt'],
      adminId: transaction['admin_id'],
      timestamp: transaction['timestamp'],
    );
  }

  Map<String, dynamic> toMap() => {
        'value': value,
        'description': description,
        'without_receipt': withoutReceipt,
        'admin_id': adminId,
        'timestamp': timestamp,
      };

  @override
  String toString() => toMap().toString();
}
