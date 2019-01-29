class User {
  String username;
  int userId;
  int activeTokens;
  String _token;
  int credit;

  User({this.username, this.userId, this.activeTokens, this.credit});

  factory User.fromMap(dynamic obj) => User(
        username: obj['name'],
        userId: obj['id'],
        credit: obj['credit'],
        activeTokens: obj['tokens'],
      );

  String get token => _token;
  set token(String token) => this._token = token;
  bool tokenExists() => (_token != null);

  Map<String, dynamic> toMap() => {
        'name': username,
        'id': userId,
        'credit': credit,
        'tokens': activeTokens
      };

  @override
  String toString() => toMap().toString();
}
