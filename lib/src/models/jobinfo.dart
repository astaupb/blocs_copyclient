/// JobInfo holds all information about jobs that you ant change at all
/// Those are most commonly determined at upload/dispatching time
class JobInfo {
  final String filename;
  final int pagecount;
  final bool color;
  final bool a3;
  final String password;

  /// JobInfo with default values
  JobInfo(
      {this.filename: '',
      this.pagecount: 0,
      this.color: true,
      this.a3: false,
      this.password: ''});

  /// Build JobInfo object from map
  factory JobInfo.fromMap(Map<String, dynamic> info) => JobInfo(
        filename: info['filename'],
        pagecount: info['pagecount'],
        color: info['color'],
        a3: info['a3'],
        password: info['password'],
      );

  Map<String, dynamic> toMap() => {
        'filename': filename,
        'pagecount': pagecount,
        'color': color,
        'a3': a3,
        'password': password
      };

  @override
  String toString() => toMap().toString();
}
