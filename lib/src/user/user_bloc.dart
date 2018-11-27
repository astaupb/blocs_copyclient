import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';

import '../models/user.dart';
import '../models/backend.dart';
import 'user_events.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final Logger log = Logger('UserBloc');

  User _user;

  get user => _user;

  String _token;
  Backend _backend;

  UserBloc(this._backend, this._token) {
    log.fine('$this started');
  }

  @override
  UserState get initialState => UserState.init();

  @override
  void dispose() {
    log.fine('disposing of $this');
    super.dispose();
  }

  @override
  Stream<UserState> mapEventToState(UserState state, UserEvent event) async* {
    log.fine(event);

    if (event is RefreshUser || event is InitUser) {
      yield UserState.busy();
      try {
        await _getUser();
        yield UserState.result(_user);
      } catch (e) {
        log.severe(e);
        yield UserState.error(e);
      }
    }

    if (event is ChangeUsername) {
      try {
        await _changeUsername(event);
        yield UserState.result(_user);
      } catch (e) {
        log.severe(e);
        yield UserState.error(e);
      }
    }
  }

  onChangeUsername(String username) =>
      dispatch(ChangeUsername(username: username));

  onRefresh() => dispatch(RefreshUser());

  onStart() => dispatch(InitUser());

  @override
  void onTransition(Transition<UserEvent, UserState> transition) {
    log.fine(transition.nextState);
    super.onTransition(transition);
  }

  /// PUT /user/username
  Future<void> _changeUsername(ChangeUsername event) async {
    Request request = ApiRequest('PUT', '/user/username', _backend);
    request.headers['Content-Type'] = 'application/json';
    request.headers['X-Api-Key'] = _token;
    request.body = json.encode(event.username);

    log.finer(request);

    return await _backend.send(request).then((response) {
      if (response.statusCode == 205) {
        _user.username = event.username;
      } else {
        throw Exception(
            '_changeUsername: received response code other than 205 (${response.statusCode})');
      }
    });
  }

  /// GET /user
  Future<void> _getUser() async {
    BaseRequest request = ApiRequest('GET', '/user', _backend);
    request.headers['X-Api-Key'] = _token;
    request.headers['Accept'] = 'application/json';

    log.finer(request);

    return await _backend.send(request).then(
      (response) async {
        if (response.statusCode == 200) {
          /// move [responseMap] entries into the global [User] object
          _user = User.fromMap(
              json.decode(utf8.decode(await response.stream.toBytes())));
          _user.token = _token;
        } else {
          throw Exception(
              '_getUser: received response code other than 200 (${response.statusCode})');
        }
      },
    );
  }
}
