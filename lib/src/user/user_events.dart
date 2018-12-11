import 'package:meta/meta.dart';

class ChangeUsername extends UserEvent {
  final String username;

  ChangeUsername({@required this.username});

  Map<String, dynamic> toMap() => {'username': username};

  @override
  String toString() => toMap().toString();
}

class InitUser extends UserEvent {
  String token;
  
  InitUser(this.token);

  Map<String, dynamic> toMap() => {'token': token};

  @override
  toString() => toMap().toString();
}

class RefreshUser extends UserEvent {}

class UserEvent {}
