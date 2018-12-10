import 'dart:io';

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

class InitJobs extends JoblistEvent {}

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
  final File file;
  final String filename;
  final JobOptions options;

  UploadJob({@required this.file, this.filename, this.options});

  Map<String, dynamic> toMap() => {
        'file': file.path,
        'filename': filename,
        'options': options.toMap(),
      };

  @override
  String toString() => toMap().toString();
}
