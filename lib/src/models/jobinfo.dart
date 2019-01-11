/// JobInfo holds all information about jobs that you ant change at all
/// Those are most commonly determined at upload/dispatching time
class JobInfo {
  final String filename;
  final String title;
  final int pagecount;
  final int colored;
  final bool a3;
  final String password;

  /// JobInfo with default values
  JobInfo(
      {this.filename: '',
      this.title: '',
      this.pagecount: 0,
      this.colored: 0,
      this.a3: false,
      this.password: ''});

  /// Build JobInfo object from map
  factory JobInfo.fromMap(Map<String, dynamic> info) => JobInfo(
        filename: info['filename'],
        pagecount: info['pagecount'],
        colored: info['colored'],
        a3: info['a3'],
        password: info['password'],
      );

  Map<String, dynamic> toMap() => {
        'filename': filename,
        'pagecount': pagecount,
        'colored': colored,
        'a3': a3,
        'password': password
      };

  @override
  String toString() => toMap().toString();
}
