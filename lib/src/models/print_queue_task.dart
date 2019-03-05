class PrintQueueTask {
  final String uid;
  final int userId;

  PrintQueueTask(this.uid, this.userId);

  factory PrintQueueTask.fromMap(Map<String, dynamic> task) =>
      PrintQueueTask(task['uid'], task['user_id']);

  Map<String, dynamic> toMap() => {'uid': uid, 'user_id': userId};

  @override
  String toString() => toMap().toString();
}
