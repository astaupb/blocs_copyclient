import 'package:meta/meta.dart';

class UserEvent {}

class ChangeUsername extends UserEvent {
  final String username;

  ChangeUsername({@required this.username});

  Map<String, dynamic> toMap() => {'username': username};

  @override
  String toString() => toMap().toString();
}

class RefreshUser extends UserEvent {}

class InitUser extends UserEvent {}
