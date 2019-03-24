import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';

import '../../exceptions.dart';
import '../models/backend.dart';
import '../models/user.dart';
import 'user_events.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final Logger log = Logger('UserBloc');

  User _user;

  String _token;

  Backend _backend;
  UserBloc(this._backend) {
    log.fine('$this started');
  }

  @override
  UserState get initialState => UserState.init();

  get user => _user;

  @override
  void dispose() {
    log.fine('disposing of $this');
    super.dispose();
  }

  @override
  Stream<UserState> mapEventToState(UserState state, UserEvent event) async* {
    log.fine(event);

    if (event is InitUser) _token = event.token;

    if (event is RefreshUser || event is InitUser) {
      yield UserState.busy();
      try {
        await _getUser();
        yield UserState.result(_user);
      } on ApiException catch (e) {
        log.severe(e);
        yield UserState.exception(e);
      }
    }

    if (event is ChangeUsername) {
      try {
        await _putUsername(event.username);
        yield UserState.result(_user);
      } on ApiException catch (e) {
        log.severe(e);
        yield UserState.exception(e);
      }
    }

    if (event is ChangePassword) {
      try {
        await _putPassword(event.oldPassword, event.newPassword);
        yield UserState.result(user);
      } on ApiException catch (e) {
        log.severe(e);
        yield UserState.exception(e);
      }
    }
  }

  onChangePassword(String oldPassword, String newPassword) =>
      dispatch(ChangePassword(oldPassword, newPassword));

  onChangeUsername(String username) =>
      dispatch(ChangeUsername(username: username));

  onRefresh() => dispatch(RefreshUser());

  onStart(String token) => dispatch(InitUser(token));

  @override
  void onTransition(Transition<UserEvent, UserState> transition) {
    log.fine(transition.nextState);
    super.onTransition(transition);
  }

  /// GET /user
  Future<void> _getUser() async {
    BaseRequest request = ApiRequest('GET', '/user', _backend);
    request.headers['X-Api-Key'] = _token;
    request.headers['Accept'] = 'application/json';

    log.finer('[_getUser] request: $request');

    return await _backend.send(request).then(
      (response) async {
        if (response.statusCode == 200) {
          log.finer('[_getUser] response: ${response.statusCode}');

          /// move [responseMap] entries into the global [User] object
          _user = User.fromMap(
              json.decode(utf8.decode(await response.stream.toBytes())));
          _user.token = _token;
        } else {
          throw ApiException(response.statusCode,
              info: '_getUser: received response code other than 200');
        }
      },
    );
  }

  /// POST /user/password
  Future<void> _putPassword(String oldPassword, String newPassword) async {
    Request request = ApiRequest('PUT', '/user/password', _backend);
    request.headers['Content-Type'] = 'application/json';
    request.headers['X-Api-Key'] = _token;
    request.body = json.encode({
      'password': {
        'old': oldPassword,
        'new': newPassword,
      }
    });

    log.finer('[_putPassword] request: $request');

    return await _backend.send(request).then((response) {
      log.finer('[_putPassword] response: ${response.statusCode}');
      if (response.statusCode == 204) {
      } else {
        throw ApiException(response.statusCode,
            info: '_putPassword: received response code other than 204');
      }
    });
  }

  /// PUT /user/username
  Future<void> _putUsername(String username) async {
    Request request = ApiRequest('PUT', '/user/name', _backend);
    request.headers['Content-Type'] = 'application/json';
    request.headers['X-Api-Key'] = _token;
    request.body = json.encode(username);

    log.finer('[_putUsername] request: $request');

    return await _backend.send(request).then((response) {
      log.finer('[_putUsername] response: ${response.statusCode}');
      if (response.statusCode == 205) {
        _user.name = username;
      } else {
        throw ApiException(response.statusCode,
            info: '_putUsername: received response code other than 205');
      }
    });
  }
}
