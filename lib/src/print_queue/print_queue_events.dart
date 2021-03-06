class AppendJob extends PrintQueueEvent {
  int jobId;

  AppendJob(this.jobId);

  Map<String, dynamic> toMap() => {'jobId': jobId};

  @override
  String toString() => toMap().toString();
}

class CancelJob extends PrintQueueEvent {
  String uid;

  CancelJob({this.uid});

  Map<String, dynamic> toMap() => {'uid': uid};

  @override
  String toString() => toMap().toString();
}

class InitPrintQueue extends PrintQueueEvent {
  String token;

  InitPrintQueue(this.token);

  Map<String, dynamic> toMap() => {'token': token};

  @override
  String toString() => toMap().toString();
}

class LockQueue extends PrintQueueEvent {
  String queueUid;

  LockQueue({this.queueUid});

  Map<String, dynamic> toMap() => {'queueUid': queueUid};

  @override
  String toString() => toMap().toString();
}

abstract class PrintQueueEvent {}

class SetDeviceId extends PrintQueueEvent {
  int deviceId;

  SetDeviceId(this.deviceId);

  Map<String, dynamic> toMap() => {'deviceId': deviceId};

  @override
  String toString() => toMap().toString();
}
