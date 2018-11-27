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

class Login extends AuthEvent {
  final String username;
  final String password;

  Login({@required this.username, @required this.password});

  Map<String, dynamic> toMap() => {'username': username, 'password': password};

  @override
  String toString() => 'Login ' + toMap().toString();
}

class Logout extends AuthEvent {}
