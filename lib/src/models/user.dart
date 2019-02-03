class User {
  String name;
  int userId;
  int activeTokens;
  String _token;
  int tokenId;
  int credit;

  User({this.name, this.userId, this.activeTokens, this.tokenId, this.credit});

  factory User.fromMap(dynamic obj) => User(
        name: obj['name'],
        userId: obj['id'],
        credit: obj['credit'],
        activeTokens: obj['tokens'],
        tokenId: obj['token_id'],
      );

  String get token => _token;
  set token(String token) => this._token = token;
  bool tokenExists() => (_token != null);

  Map<String, dynamic> toMap() => {
        'name': name,
        'id': userId,
        'credit': credit,
        'tokens': activeTokens,
        'tokenId': tokenId,
      };

  @override
  String toString() => toMap().toString();
}
