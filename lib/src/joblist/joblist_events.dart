import 'package:meta/meta.dart';

import '../models/joboptions.dart';

/// [DeleteJob] _needs_ to have either [id] or [index] set
class DeleteJob extends JoblistEvent {
  final int id;
  final int index;

  DeleteJob({this.id, this.index});

  Map<String, dynamic> toMap() => {'id': id, 'index': index};

  @override
  String toString() => toMap().toString();
}

class InitJobs extends JoblistEvent {
  final String token;

  InitJobs(this.token);

  Map<String, dynamic> toMap() => {'token': token};

  @override
  String toString() => toMap().toString();
}

abstract class JoblistEvent {}

/// [PrintJob] _needs_ to have either [id] or [index] set
class PrintJob extends JoblistEvent {
  final String deviceId;
  final int id;
  final int index;

  PrintJob({@required this.deviceId, this.id, this.index});

  Map<String, dynamic> toMap() => {
        'deviceId': deviceId,
        'id': id,
        'index': index,
      };

  @override
  String toString() => toMap().toString();
}

/// Demand refreshing all jobs, or if [index] is set only that one
class RefreshJobs extends JoblistEvent {}

class UploadJob extends JoblistEvent {
  final List<int> data;
  final String filename;
  final JobOptions options;

  UploadJob({@required this.data, this.filename, this.options});

  Map<String, dynamic> toMap() => {
        'file': data,
        'filename': filename,
        'options': options.toMap(),
      };

  @override
  String toString() => toMap().toString();
}
