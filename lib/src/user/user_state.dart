import '../models/user.dart';
import '../common.dart';
import '../../exceptions.dart';

class UserState extends ResultState<User> {
  UserState({
    User user,
    ApiException error,
    bool isInit = false,
    bool isBusy = false,
    bool isResult = false,
    bool isException = false,
  }) : super(
            value: user,
            error: error,
            isResult: isResult,
            isInit: isInit,
            isBusy: isBusy,
            isException: isException);

  factory UserState.busy() => UserState(isBusy: true);

  factory UserState.init() => UserState(isInit: true);

  factory UserState.result(User user) => UserState(isResult: true, user: user);

  factory UserState.exception(ApiException e) => UserState(isException: true, error: e);

  Map<String, dynamic> toMap() => {
        'user': (value != null) ? value : 'null',
        'error': (error != null) ? error : 'null',
        'isInit': isInit,
        'isBusy': isBusy,
        'isResult': isResult,
        'isException': isException
      };

  @override
  String toString() => toMap().toString();
}
