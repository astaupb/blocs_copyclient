import 'package:meta/meta.dart';

class ChangePassword extends UserEvent {
  final String oldPassword;
  final String newPassword;

  ChangePassword(this.oldPassword, this.newPassword);

  Map<String, dynamic> toMap() => {
        'password': {
          'old': oldPassword,
          'new': newPassword,
        }
      };

  @override
  String toString() => toMap().toString();
}

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
