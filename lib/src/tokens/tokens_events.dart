abstract class TokensEvent {}

class InitTokens extends TokensEvent {
  String token;

  InitTokens(this.token);

  Map<String, dynamic> toMap() => {'token': token};

  @override
  String toString() => toMap().toString();
}

class GetTokens extends TokensEvent {}

class DeleteToken extends TokensEvent {
  final int id;

  DeleteToken(this.id);

  Map<String, dynamic> toMap() => {'id': id};

  @override
  String toString() => toMap().toString();
}
