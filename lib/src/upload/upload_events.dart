import 'dart:io';

import 'package:meta/meta.dart';

import '../models/joboptions.dart';

class UploadEvent {}

class InitUploads extends UploadEvent {}

class RefreshUploads extends UploadEvent {}

class UploadFile extends UploadEvent {
  final File file;
  final bool color;
  final String filename;
  final String password;

  UploadFile({
    @required this.file,
    this.color = true,
    this.filename = '',
    this.password = '',
  });

  Map<String, dynamic> toMap() => {
        'file': file.path,
        'color': color,
        'filename': filename,
        'password': password,
      };

  @override
  String toString() => toMap().toString();
}
