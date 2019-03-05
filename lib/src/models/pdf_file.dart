class PdfFile {
  final List<int> file;
  final String uid;
  final String name;

  PdfFile(this.file, this.uid, {this.name});

  Map<String, dynamic> toMap() => {
        'file.length)': file.length,
        'uid': uid,
        'name': name,
      };

  @override
  String toString() => toMap().toString();
}
