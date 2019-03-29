import '../common.dart';
import '../../exceptions.dart';

class AuthState extends CommonState {
  final String token;
  final bool persistent;
  final String username;

  final bool isUnauthorized;
  final bool isAuthorized;
  final bool isRegistered;

  AuthState({
    this.token,
    this.persistent,
    ApiException error,
    bool isInit = false,
    bool isBusy = false,
    bool isException = false,
    this.isUnauthorized = false,
    this.isAuthorized = false,
    this.username,
    this.isRegistered,
  }) : super(
          error: error,
          isInit: isInit,
          isBusy: isBusy,
          isException: isException,
        );

  factory AuthState.authorized(String token, {bool persistent = false}) =>
      AuthState(isAuthorized: true, token: token, persistent: persistent);

  factory AuthState.registered(String username) =>
      AuthState(isRegistered: true, username: username);

  factory AuthState.busy() => AuthState(isBusy: true);

  factory AuthState.exception(ApiException e) => AuthState(isException: true, error: e);

  factory AuthState.init() => AuthState(isInit: true);

  factory AuthState.unauthorized() => AuthState(isUnauthorized: true);

  Map<String, dynamic> toMap() => {
        'isInit': isInit,
        'isBusy': isBusy,
        'isAuthorized': isAuthorized,
        'isUnauthorized': isUnauthorized,
        'isException': isException,
        'token': token,
        'persistent': persistent,
        'error': error.toString(),
      };

  @override
  String toString() => toMap().toString();
}
