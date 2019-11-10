import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:blocs_copyclient/src/models/joboptions.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';

import '../../exceptions.dart';
import '../models/backend.dart';
import '../models/user.dart';
import 'user_events.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final Logger _log = Logger('UserBloc');

  User _user;

  String _token;

  Backend _backend;
  UserBloc(this._backend) {
    _log.fine('$this started');
  }

  @override
  UserState get initialState => UserState.init();

  get user => _user;

  @override
  Stream<UserState> mapEventToState(UserEvent event) async* {
    _log.fine(event);

    if (event is InitUser) _token = event.token;

    if (event is RefreshUser || event is InitUser) {
      yield UserState.busy();
      try {
        await _getUser();
        yield UserState.result(_user);
      } on ApiException catch (e) {
        _log.severe(e);
        yield UserState.exception(e);
      }
    } else if (event is ChangeUsername) {
      try {
        await _putUsername(event.username);
        yield UserState.result(_user);
      } on ApiException catch (e) {
        _log.severe(e);
        yield UserState.exception(e);
      }
    } else if (event is ChangePassword) {
      try {
        await _putPassword(event.oldPassword, event.newPassword);
        yield UserState.result(_user);
      } on ApiException catch (e) {
        _log.severe(e);
        yield UserState.exception(e);
      }
    } else if (event is GetOptions) {
      try {
        await _getOptions();
        yield UserState.result(_user);
      } on ApiException catch (e) {
        _log.severe(e);
        yield UserState.exception(e);
      }
    } else if (event is ChangeOptions) {
      try {
        await _putOptions(event.options);
        yield UserState.result(_user);
      } on ApiException catch (e) {
        _log.severe(e);
        yield UserState.exception(e);
      }
    }
  }

  void onChangeOptions(JobOptions options) => this.add(ChangeOptions(options));

  void onChangePassword(String oldPassword, String newPassword) =>
      this.add(ChangePassword(oldPassword, newPassword));

  void onChangeUsername(String username) =>
      this.add(ChangeUsername(username: username));

  void onGetOptions() => this.add(GetOptions());

  void onRefresh() => this.add(RefreshUser());

  void onStart(String token) => this.add(InitUser(token));

  @override
  void onTransition(Transition<UserEvent, UserState> transition) {
    _log.fine(
        'Transition from ${transition.currentState} to ${transition.nextState}');
    super.onTransition(transition);
  }

  /// GET /user/options
  Future<void> _getOptions() async {
    BaseRequest request = ApiRequest('GET', '/user/options', _backend);
    request.headers['X-Api-Key'] = _token;
    request.headers['Accept'] = 'application/json';

    _log.finer('[_getOptions] request: $request');

    return await _backend.send(request).then(
      (response) async {
        if (response.statusCode == 200) {
          String responseString = await response.stream.bytesToString();
          _log.finer(
              '[_getOptions] response: ${response.statusCode} $responseString');

          _user.options = JobOptions.fromMap(json.decode(responseString));
          return;
        } else {
          throw ApiException(response.statusCode,
              info: '_getOptions: received response code other than 200');
        }
      },
    );
  }

  /// GET /user
  Future<void> _getUser() async {
    BaseRequest request = ApiRequest('GET', '/user', _backend);
    request.headers['X-Api-Key'] = _token;
    request.headers['Accept'] = 'application/json';

    _log.finer('[_getUser] request: $request');

    return await _backend.send(request).then(
      (response) async {
        if (response.statusCode == 200) {
          _log.finer('[_getUser] response: ${response.statusCode}');

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

  /// PUT /user/options
  Future<void> _putOptions(JobOptions options) async {
    Request request = ApiRequest('PUT', '/user/options', _backend);
    request.headers['Content-Type'] = 'application/json';
    request.headers['X-Api-Key'] = _token;

    request.bodyBytes = utf8.encode(json.encode(options.toMap()));

    _log.finer('[_putOptions] request: $request');

    return await _backend.send(request).then((response) {
      _log.finer('[_putOptions] response: ${response.statusCode}');
      if (response.statusCode == 205) {
        _user.options = options;
        return;
      } else {
        throw ApiException(response.statusCode,
            info: '_putOptions: received response code other than 205');
      }
    });
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

    _log.finer('[_putPassword] request: $request');

    return await _backend.send(request).then((response) {
      _log.finer('[_putPassword] response: ${response.statusCode}');
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

    _log.finer('[_putUsername] request: $request');

    return await _backend.send(request).then((response) {
      _log.finer('[_putUsername] response: ${response.statusCode}');
      if (response.statusCode == 205) {
        _user.name = username;
      } else {
        throw ApiException(response.statusCode,
            info: '_putUsername: received response code other than 205');
      }
    });
  }
}
