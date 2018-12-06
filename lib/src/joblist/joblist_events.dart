import 'dart:io';

import 'package:meta/meta.dart';

import '../models/joboptions.dart';

/// [DeleteJob] _needs_ to have either [uid] or [index] set
class DeleteJob extends JoblistEvent {
  final String uid;
  final int index;

  DeleteJob({this.uid, this.index});

  Map<String, dynamic> toMap() => {'uid': uid, 'index': index};

  @override
  String toString() => toMap().toString();
}

class InitJobs extends JoblistEvent {}

abstract class JoblistEvent {}

/// [PrintJob] _needs_ to have either [uid] or [index] set
class PrintJob extends JoblistEvent {
  final String deviceId;
  final String uid;
  final int index;

  PrintJob({@required this.deviceId, this.uid, this.index});

  Map<String, dynamic> toMap() => {
        'deviceId': deviceId,
        'uid': uid,
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
