import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import '../../exceptions.dart';
import '../models/backend.dart';
import 'auth_events.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Logger log = Logger('AuthBloc');

  String token;
  Backend backend;

  AuthBloc({@required this.backend, this.token}) {
    log.info('$this started');
  }

  @override
  AuthState get initialState => AuthState.unauthorized();

  @override
  Stream<AuthState> mapEventToState(AuthEvent event) async* {
    log.fine('Event: $event');
    if (event is Login) {
      yield AuthState.busy();
      try {
        await _postToken(event);
        yield AuthState.authorized(token, persistent: event.persistent);
      } on ApiException catch (e) {
        log.severe(e.info);
        yield AuthState.exception(e);
      }
    } else if (event is TokenLogin) {
      yield AuthState.busy();
      try {
        token = event.token;
        yield AuthState.authorized(token);
      } on ApiException catch (e) {
        log.severe(e.info);
        yield AuthState.exception(e);
      }
    } else if (event is LogoutToken) {
      yield AuthState.busy();
      try {
        await _deleteToken(id: event.id);
        yield AuthState.unauthorized();
      } on ApiException catch (e) {
        log.severe(e.info);
        yield AuthState.exception(e);
      }
    } else if (event is Register) {
      try {
        await _postUser(event.username, event.password);
        yield AuthState.registered(event.username);
      } on ApiException catch (e) {
        yield AuthState.exception(e);
      }
    } else if (event is Logout) {
      try {
        await _logout();
        yield AuthState.unauthorized();
      } on ApiException catch (e) {
        yield AuthState.exception(e);
      }
    }
  }

  void onDeleteToken() => this.add(LogoutToken());

  void onLogin(String username, String password, {bool persistent = false}) =>
      this.add(Login(
          username: username, password: password, persistent: persistent));

  void onRegister(String username, String password) =>
      this.add(Register(username, password));

  void onTokenLogin(String token) => this.add(TokenLogin(token: token));

  @override
  void onTransition(Transition<AuthEvent, AuthState> transition) {
    log.fine('State: ${transition.nextState}');
    super.onTransition(transition);
  }

  Future<void> _deleteToken({int id}) async {
    log.fine('_deleteToken');
    String path = '/user/tokens';
    if (id != null) path += '/$id';
    http.BaseRequest request = ApiRequest('DELETE', path, backend);

    request.headers['X-Api-Key'] = token;

    log.finer('_deleteToken: $request');

    return await backend.send(request).then(
      (response) async {
        log.finer('_deleteToken: ${response.statusCode}');
        if (response.statusCode == 205) {
          token = '';
          return;
        } else {
          throw ApiException(response.statusCode,
              info: '_postToken: received response code other than 205');
        }
      },
    ).timeout(Duration(seconds: 10),
        onTimeout: () =>
            throw ApiException(0, info: '_deleteToken: connection timed out'));
  }

  Future<void> _logout() async {
    log.fine('_logout');
    http.BaseRequest request = ApiRequest('POST', '/user/logout', backend);

    request.headers['X-Api-Key'] = token;

    log.finer('_logout: $request');

    return await backend.send(request).then(
      (response) async {
        log.finer('_logout: ${response.statusCode}');
        if (response.statusCode == 205) {
          token = '';
          return;
        } else {
          throw ApiException(response.statusCode,
              info: '_logout: received status code other than 205');
        }
      },
    ).timeout(Duration(seconds: 10),
        onTimeout: () =>
            throw ApiException(0, info: '_logout: connection timed out'));
  }

  /// POST /user/tokens and then GET /user to update the global [User] object
  Future<void> _postToken(Login initEvent) async {
    log.fine('_postToken: ${initEvent.toString()}');
    http.BaseRequest request = ApiRequest('POST', '/user/tokens', backend);
    request.headers['Accept'] = 'application/json';
    request.headers['Authorization'] = ('Basic ' +
        base64.encode(
            utf8.encode(initEvent.username + ':' + initEvent.password)));

    log.finer('_postToken: $request');

    await backend.send(request).then(
      (response) async {
        log.finer('_postToken: ${response.statusCode}');
        if (response.statusCode == 200) {
          token = json.decode(await response.stream.bytesToString());
        } else {
          throw ApiException(response.statusCode,
              info: '_postToken: received response code other than 200');
        }
      },
    ).timeout(Duration(seconds: 10),
        onTimeout: () =>
            throw ApiException(0, info: '_postToken: connection timed out'));
  }

  Future<void> _postUser(String username, String password) async {
    http.Request request = ApiRequest('POST', '/user', backend);
    request.headers['Content-Type'] = 'application/json';

    request.body = json.encode({
      'name': username,
      'password': password,
    });

    log.finer('_postUser: $request');

    await backend.send(request).then(
      (http.StreamedResponse response) async {
        log.finer('_postUser: ${response.statusCode}');
        if (response.statusCode == 204) {
          return;
        } else {
          log.severe('_postUser: ${(await response.stream.bytesToString())}');
          throw ApiException(response.statusCode);
        }
      },
    ).timeout(Duration(seconds: 10),
        onTimeout: () =>
            throw ApiException(0, info: '_postUser: connection timed out'));
  }
}
