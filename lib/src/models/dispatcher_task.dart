import 'package:meta/meta.dart';

class DispatcherTask {
  final String filename;
  bool isUploading;
  String uid;
  int localId;

  DispatcherTask({
    @required this.isUploading,
    @required this.filename,
    this.uid,
    this.localId = -1,
  });

  factory DispatcherTask.fromMap(Map<String, dynamic> map) => DispatcherTask(
        isUploading: false,
        filename: map['filename'],
        uid: map['uid'],
      );

  Map<String, dynamic> toMap() => {
        'isUploading': isUploading,
        'filename': filename,
        'uid': uid,
      };

  @override
  String toString() => toMap().toString();
}
