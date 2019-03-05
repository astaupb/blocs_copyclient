class PdfFile {
  final List<int> file;
  final int id;
  final String name;

  PdfFile(this.file, this.id, {this.name});

  Map<String, dynamic> toMap() => {
        'file.length)': file.length,
        'id': id,
        'name': name,
      };

  @override
  String toString() => toMap().toString();
}
