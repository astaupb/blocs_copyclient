import 'joboptions.dart';

class User {
  String name;
  String email;
  int userId;
  int card;
  int pin;
  int activeTokens;
  String _token;
  int tokenId;
  int credit;
  JobOptions options;

  User(
      {this.name,
      this.email,
      this.userId,
      this.card,
      this.pin,
      this.activeTokens,
      this.tokenId,
      this.credit,
      this.options});

  factory User.fromMap(dynamic obj) => User(
        name: obj['name'],
        email: obj['email'],
        userId: obj['id'],
        card: obj['card'],
        pin: obj['pin'],
        credit: obj['credit'],
        activeTokens: obj['tokens'],
        tokenId: obj['token_id'],
      );

  String get token => _token;
  set token(String token) => this._token = token;
  bool tokenExists() => (_token != null);

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'id': userId,
        'card': card,
        'pin': pin,
        'credit': credit,
        'tokens': activeTokens,
        'tokenId': tokenId,
      };

  @override
  String toString() => toMap().toString();
}
