import 'package:meta/meta.dart';

import '../models/backend.dart';

class AuthEvent {}

class AuthInit extends AuthEvent {
  final Backend backend;

  AuthInit({@required this.backend});

  Map<String, dynamic> toMap() => {'backend': backend.toMap()};

  @override
  String toString() => 'AuthInit ' + toMap().toString();
}

class LogoutToken extends AuthEvent {
  final int id;

  LogoutToken({this.id});

  Map<String, dynamic> toMap() => {'id': id};

  @override
  String toString() => 'Delete Token ' + toMap().toString();
}

class Login extends AuthEvent {
  final String username;
  final String password;
  final bool persistent;

  Login({@required this.username, @required this.password, this.persistent = false});

  Map<String, dynamic> toMap() =>
      {'username': username, 'password': password, 'persistent': persistent};

  @override
  String toString() => 'Login ' + toMap().toString();
}

class Logout extends AuthEvent {}

class Register extends AuthEvent {
  final String username;
  final String password;
  final String email;

  Register(this.username, this.password, this.email);

  Map<String, dynamic> toMap() => {
        'username': username,
        'password': password,
        'email': email,
      };

  @override
  String toString() => toMap().toString();
}

class TokenLogin extends AuthEvent {
  final String token;

  TokenLogin({@required this.token});

  Map<String, dynamic> toMap() => {'token': token};

  @override
  String toString() => toMap().toString();
}
