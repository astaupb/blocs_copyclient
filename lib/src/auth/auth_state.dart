import '../common.dart';

class AuthState extends CommonState {
  final String token;

  final bool isUnauthorized;
  final bool isAuthorized;

  AuthState({
    this.token,
    String error,
    bool isInit = false,
    bool isBusy = false,
    bool isError = false,
    this.isUnauthorized = false,
    this.isAuthorized = false,
  }) : super(err: error, isInit: isInit, isBusy: isBusy, isError: isError);

  factory AuthState.authorized(String token) =>
      AuthState(isAuthorized: true, token: token);

  factory AuthState.busy() => AuthState(isBusy: true);

  factory AuthState.error(String e) => AuthState(isError: true, error: e);

  factory AuthState.init() => AuthState(isInit: true);

  factory AuthState.unauthorized() => AuthState(isUnauthorized: true);

  Map<String, dynamic> toMap() => {
        'isInit': isInit,
        'isBusy': isBusy,
        'isAuthorized': isAuthorized,
        'isUnauthorized': isUnauthorized,
        'isError': isError,
        'token': token,
        'error': err.toString(),
      };

  @override
  String toString() => toMap().toString();
}