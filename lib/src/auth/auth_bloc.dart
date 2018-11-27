import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import '../models/backend.dart';
import 'auth_events.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Logger log = Logger('AuthBloc');

  String _token;
  Backend backend;

  AuthBloc({@required this.backend});

  @override
  AuthState get initialState => AuthState.init();

  void init(Backend backend) => dispatch(AuthInit(backend: backend));

  void login(String user, String pw) =>
      dispatch(Login(username: user, password: pw));

  void logout() => dispatch(Logout());

  @override
  Stream<AuthState> mapEventToState(AuthState state, AuthEvent event) async* {
    log.fine('Event: $event');
    if (event is AuthInit) {
      backend = event.backend;
      yield AuthState.unauthorized();
    } else if (event is Login && state.isUnauthorized) {
      yield AuthState.busy();
      try {
        await _postLogin(event);
        yield AuthState.authorized(_token);
      } catch (e) {
        log.severe(e);
        yield AuthState.error(e.toString().split('Error:')[0]);
      }
    } else if (event is Logout && state.isAuthorized) {
      yield AuthState.busy();
      try {
        //delete token and database entry
        _token = '';
        yield AuthState.unauthorized();
      } catch (e) {
        yield AuthState.error(e.toString().split('Error:')[0]);
      }
    }
  }

  @override
  void onTransition(Transition<AuthEvent, AuthState> transition) {
    log.fine('State: ${transition.nextState}');
    super.onTransition(transition);
  }

  /// POST /user/login and then GET /user to update the global [User] object
  Future<void> _postLogin(Login initEvent) async {
    http.BaseRequest request = ApiRequest('POST', '/user/login', backend);
    request.headers['Accept'] = 'text/plain';
    request.headers['Authorization'] = ('Basic ' +
        base64.encode(
            utf8.encode(initEvent.username + ':' + initEvent.password)));

    log.finer('_postLogin: $request');

    await backend.send(request).then((response) async {
      log.finer('_postLogin: ${response.statusCode}');
      if (response.statusCode == 200) {
        _token = await response.stream.bytesToString();
      } else {
        throw Exception(
            '_postLogin: received response code other than 200 (${response.statusCode})');
      }
    });
  }
}
