import 'package:meta/meta.dart';

class DispatcherTask {
  final String filename;
  final bool color;
  bool isUploading;
  String uid;
  int localId;

  DispatcherTask({
    @required this.isUploading,
    @required this.filename,
    @required this.color,
    this.uid,
    this.localId = -1,
  });

  factory DispatcherTask.fromMap(Map<String, dynamic> map) => DispatcherTask(
        isUploading: false,
        filename: map['filename'],
        color: map['color'],
        uid: map['uid'],
      );

  Map<String, dynamic> toMap() => {
        'isUploading': isUploading,
        'filename': filename,
        'color': color,
        'uid': uid,
      };

  @override
  String toString() => toMap().toString();
}
