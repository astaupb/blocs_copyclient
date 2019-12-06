import 'package:blocs_copyclient/upload.dart';
import 'package:meta/meta.dart';

class UploadProgress {
  int current;
  int total;

  UploadProgress({this.current = 0, this.total = 0});

  @override
  String toString() => '[UploadProgress $current/$total]';
}

class DispatcherTask {
  final String filename;
  bool isUploading;
  String uid;
  int localId;

  UploadProgress progress;

  DispatcherTask({
    @required this.isUploading,
    @required this.filename,
    this.uid,
    this.localId = -1,
    this.progress,
  });

  factory DispatcherTask.fromMap(Map<String, dynamic> map) => DispatcherTask(
        filename: map['filename'],
        isUploading: false,
        uid: map['uid'],
      );

  Map<String, dynamic> toMap() => {
        'filename': filename,
        'isUploading': isUploading,
        'uid': uid,
        'local_id': localId,
        'progress': progress.toString(),
      };

  @override
  String toString() => toMap().toString();
}
