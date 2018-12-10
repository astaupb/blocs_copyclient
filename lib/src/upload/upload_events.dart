import 'package:meta/meta.dart';

class UploadEvent {}

class InitUploads extends UploadEvent {}

class RefreshUploads extends UploadEvent {}

class UploadFile extends UploadEvent {
  final List<int> data;
  final bool color;
  final String filename;
  final String password;

  UploadFile({
    @required this.data,
    this.color = true,
    this.filename = '',
    this.password = '',
  });

  Map<String, dynamic> toMap() => {
        'data': data,
        'color': color,
        'filename': filename,
        'password': password,
      };

  @override
  String toString() => toMap().toString();
}

/// TODO: cancel upload
