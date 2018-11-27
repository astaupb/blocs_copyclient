import '../models/user.dart';
import '../common.dart';

class UserState extends ResultState<User> {
  UserState({
    User user,
    String error,
    bool isInit = false,
    bool isBusy = false,
    bool isResult = false,
    bool isError = false,
  }) : super(
            value: user,
            isResult: isResult,
            isInit: isInit,
            isBusy: isBusy,
            isError: isError);

  factory UserState.busy() => UserState(isBusy: true);

  factory UserState.init() => UserState(isInit: true);

  factory UserState.result(User user) => UserState(isResult: true, user: user);

  factory UserState.error(String e) => UserState(isError: true, error: e);

  Map<String, dynamic> toMap() => {
        'user': (value != null) ? value : 'null',
        'error': (err != null) ? err : 'null',
        'isInit': isInit,
        'isBusy': isBusy,
        'isResult': isResult,
        'isError': isError
      };

  @override
  String toString() => toMap().toString();
}
