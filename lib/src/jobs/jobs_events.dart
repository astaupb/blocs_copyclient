import 'dart:io';

import 'package:meta/meta.dart';

import '../models/joboptions.dart';

class InitJobs extends JobsEvent {}

abstract class JobsEvent {}

class RefreshJobs extends JobsEvent {}

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
