import 'dart:io';

import 'package:meta/meta.dart';

import '../models/joboptions.dart';

/// [DeleteJob] _needs_ to have either [uid] or [index] set
class DeleteJob extends JobsEvent {
  final String uid;
  final int index;

  DeleteJob({this.uid, this.index});

  Map<String, dynamic> toMap() => {'uid': uid, 'index': index};

  @override
  String toString() => toMap().toString();
}

class InitJobs extends JobsEvent {}

class GetPdf extends JobsEvent {
  final String uid;

  GetPdf(this.uid);
}

class GetPreviews extends JobsEvent {
  final String uid;

  GetPreviews(this.uid);
}

abstract class JobsEvent {}

/// [PrintJob] _needs_ to have either [uid] or [index] set
class PrintJob extends JobsEvent {
  final int deviceId;
  final String uid;
  final int index;

  PrintJob({@required this.deviceId, this.uid, this.index});

  Map<String, dynamic> toMap() => {'uid': uid, 'index': index};

  @override
  String toString() => toMap().toString();
}

class RefreshJobs extends JobsEvent {
  final int index;

  RefreshJobs({this.index});

  @override
  String toString() => (index != null) ? index.toString() : super.toString();
}

class UploadJob extends JobsEvent {
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
