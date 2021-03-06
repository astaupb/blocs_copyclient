import 'package:blocs_copyclient/upload.dart';
import 'package:meta/meta.dart';

class AddUpload extends UploadEvent {
  final String filename;
  final UploadProgress progress;

  AddUpload(this.filename, this.progress);

  @override
  String toString() => '[AddUpload $filename $progress]';
}

class UpdateProgress extends UploadEvent {
  final int localId;
  final UploadProgress progress;

  UpdateProgress(this.localId, this.progress);

  @override
  String toString() => '[UpdateProgress $localId $progress]';
}

class InitUploads extends UploadEvent {
  final String token;
  InitUploads(this.token);

  Map<String, dynamic> toMap() => {'token': token};

  @override
  String toString() => toMap().toString();
}

class RefreshUploads extends UploadEvent {}

class UploadEvent {}

class UploadFile extends UploadEvent {
  final List<int> data;
  final bool color;
  final bool a3;
  final int duplex;
  final int copies;
  final int preprocess;
  final String filename;
  final String password;

  UploadFile({
    @required this.data,
    this.color = true,
    this.filename = '',
    this.password = '',
    this.a3 = false,
    this.duplex = 0,
    this.copies = 1,
    this.preprocess = 1,
  });

  Map<String, dynamic> toMap() => {
        'data': data.length,
        'color': color,
        'a3': a3,
        'preprocess': preprocess,
        'duplex': duplex,
        'copies': copies,
        'filename': filename,
        'password': password,
      };

  @override
  String toString() => toMap().toString();
}

/// TODO: cancel upload
