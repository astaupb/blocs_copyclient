import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import '../exceptions.dart';
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
  void dispose() {
    log.info('disposing of $this');
    backend.close();
    super.dispose();
  }

  void login(String user, String pw, {bool persistent = false}) => dispatch(
        Login(username: user, password: pw, persistent: persistent),
      );

  void deleteToken(int id) => dispatch(DeleteToken(id));

  @override
  Stream<AuthState> mapEventToState(AuthState state, AuthEvent event) async* {
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
    } else if (event is DeleteToken) {
      yield AuthState.busy();
      try {
        await _deleteToken(event.id);
        yield AuthState.unauthorized();
      } on ApiException catch (e) {
        log.severe(e.info);
        yield AuthState.exception(e);
      }
    } else if (event is Register) {
      try {
        await _postUser(event.username, event.password);
        dispatch(Login(username: event.username, password: event.password));
      } catch (e) {
        yield AuthState.exception(e);
      }
    }
  }

  @override
  void onTransition(Transition<AuthEvent, AuthState> transition) {
    log.fine('State: ${transition.nextState}');
    super.onTransition(transition);
  }

  void register(String username, String password) =>
      dispatch(Register(username, password));

  void tokenLogin(String token) => dispatch(TokenLogin(token: token));

  /// POST /user/tokens and then GET /user to update the global [User] object
  Future<void> _postToken(Login initEvent) async {
    log.fine('_postToken: ${initEvent.toString()}');
    http.BaseRequest request = ApiRequest('POST', '/user/tokens', backend);
    request.headers['Accept'] = 'application/json';
    request.headers['Authorization'] = ('Basic ' +
        base64.encode(
            utf8.encode(initEvent.username + ':' + initEvent.password)));

    log.finer('_postToken: $request');

    await backend.send(request).then((response) async {
      log.finer('_postToken: ${response.statusCode}');
      if (response.statusCode == 200) {
        token = json.decode(await response.stream.bytesToString());
      } else {
        throw ApiException(response.statusCode,
            info: '_postToken: received response code other than 200');
      }
    });
  }

  Future<void> _deleteToken(int id) async {
    log.fine('_deleteToken: $id');
    http.BaseRequest request = ApiRequest('DELETE', '/user/tokens', backend);
    request.headers['X-Api-Key'] = token;

    log.finer('_deleteToken: $request');

    await backend.send(request).then((response) async {
      log.finer('_deleteToken: ${response.statusCode}');
      if (response.statusCode == 205) {
        token = '';
      } else {
        throw ApiException(response.statusCode,
            info: '_postToken: received response code other than 205');
      }
    });
  }

  Future<void> _postUser(String username, String password) async {
    http.Request request = ApiRequest('POST', '/user', backend);
    request.headers['Content-Type'] = 'application/json';

    request.body = json.encode({
      'username': username,
      'password': password,
    });

    log.finer('_postUser: $request');

    await backend.send(request).then(
      (http.StreamedResponse response) async {
        if (response.statusCode == 204) {
          log.fine('_postUser: 204');
          return;
        } else {
          log.severe('_postUser: ${(await response.stream.bytesToString())}');
          throw ApiException(response.statusCode);
        }
      },
    );
  }
}
