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

  void login(String user, String pw) => dispatch(
        Login(username: user, password: pw),
      );

  void logout() => dispatch(Logout());

  @override
  Stream<AuthState> mapEventToState(AuthState state, AuthEvent event) async* {
    log.fine('Event: $event');
    if (event is Login) {
      yield AuthState.busy();
      try {
        await _postLogin(event);
        yield AuthState.authorized(token);
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
    } else if (event is Logout) {
      yield AuthState.busy();
      try {
        //delete token and database entry
        token = '';
        yield AuthState.unauthorized();
      } on ApiException catch (e) {
        log.severe(e.info);
        yield AuthState.exception(e);
      }
    }
  }

  @override
  void onTransition(Transition<AuthEvent, AuthState> transition) {
    log.fine('State: ${transition.nextState}');
    super.onTransition(transition);
  }

  void tokenLogin(String token) => dispatch(TokenLogin(token: token));

  /// POST /user/login and then GET /user to update the global [User] object
  Future<void> _postLogin(Login initEvent) async {
    http.BaseRequest request = ApiRequest('POST', '/user/tokens', backend);
    request.headers['Accept'] = 'application/json';
    request.headers['Authorization'] = ('Basic ' +
        base64.encode(
            utf8.encode(initEvent.username + ':' + initEvent.password)));

    log.finer('_postLogin: $request');

    await backend.send(request).then((response) async {
      log.finer('_postLogin: ${response.statusCode}');
      if (response.statusCode == 200) {
        token = json.decode(await response.stream.bytesToString());
      } else {
        throw ApiException(response.statusCode,
            info: '_postLogin: received response code other than 200');
      }
    });
  }
}
