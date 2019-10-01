import 'package:meta/meta.dart';

class UploadEvent {}

class InitUploads extends UploadEvent {
  final String token;
  InitUploads(this.token);

  Map<String, dynamic> toMap() => {'token': token};

  @override
  String toString() => toMap().toString();
}

class RefreshUploads extends UploadEvent {}

class UploadFile extends UploadEvent {
  final List<int> data;
  final bool color;
  final bool a3;
  final int duplex;
  final String filename;
  final String password;

  UploadFile({
    @required this.data,
    this.color = true,
    this.filename = '',
    this.password = '',
    this.a3 = false,
    this.duplex = 0,
  });

  Map<String, dynamic> toMap() => {
        'data': data.length,
        'color': color,
        'a3': a3,
        'duplex': duplex,
        'filename': filename,
        'password': password,
      };

  @override
  String toString() => toMap().toString();
}

/// TODO: cancel upload
