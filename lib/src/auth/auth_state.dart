import '../common.dart';
import '../exceptions.dart';

class AuthState extends CommonState {
  final String token;

  final bool isUnauthorized;
  final bool isAuthorized;

  AuthState({
    this.token,
    ApiException error,
    bool isInit = false,
    bool isBusy = false,
    bool isException = false,
    this.isUnauthorized = false,
    this.isAuthorized = false,
  }) : super(
          error: error,
          isInit: isInit,
          isBusy: isBusy,
          isException: isException,
        );

  factory AuthState.authorized(String token) =>
      AuthState(isAuthorized: true, token: token);

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
        'error': error.toString(),
      };

  @override
  String toString() => toMap().toString();
}
