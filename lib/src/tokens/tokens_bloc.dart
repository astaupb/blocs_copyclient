import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';

import '../../exceptions.dart';
import '../models/backend.dart';
import '../models/token.dart';
import 'tokens_events.dart';
import 'tokens_state.dart';

class TokensBloc extends Bloc<TokensEvent, TokensState> {
  final Logger log = Logger('TokensBloc');

  final Backend _backend;
  String _token;

  List<Token> _tokens;

  TokensBloc(this._backend) {
    log.fine('$this started');
  }

  @override
  TokensState get initialState => TokensState.init();

  @override
  void dispose() {
    log.fine('disposing of $this');
    super.dispose();
  }

  @override
  Stream<TokensState> mapEventToState(TokensEvent event) async* {
    log.fine('Event: $event');

    if (event is InitTokens) {
      _token = event.token;
    }

    if (event is GetTokens) {
      yield TokensState.busy();
      try {
        await _getTokens();
        yield TokensState.result(_tokens);
      } on ApiException catch (e) {
        yield TokensState.exception(e);
      }
    }

    if (event is DeleteToken) {
      yield TokensState.busy();
      try {
        await _deleteToken(event.id);
        yield TokensState.result(_tokens);
      } on ApiException catch (e) {
        yield TokensState.exception(e);
      }
    }
  }

  void onDeleteToken(int id) => dispatch(DeleteToken(id));

  void onGetTokens() => dispatch(GetTokens());

  void onStart(String token) => dispatch(InitTokens(token));

  @override
  void onTransition(Transition<TokensEvent, TokensState> transition) {
    log.finer('State: ${transition.nextState}');

    super.onTransition(transition);
  }

  Future<void> _deleteToken(int id) async {
    Request request = ApiRequest('DELETE', '/user/tokens/$id', _backend);
    request.headers['X-Api-Key'] = _token;

    log.finer('_deleteToken: $request');

    return await _backend.send(request).then(
      (response) async {
        log.finer('_deleteToken: ${response.statusCode}');
        if (response.statusCode == 205) {
          _tokens.removeWhere((Token tok) => tok.id == id);
          return;
        } else {
          throw ApiException(response.statusCode, info: 'status code other than 205 received');
        }
      },
    );
  }

  Future<void> _getTokens() async {
    Request request = ApiRequest('GET', '/user/tokens', _backend);
    request.headers['Accept'] = 'application/json';
    request.headers['X-Api-Key'] = _token;

    log.finer('_getTokens: $request');

    return await _backend.send(request).then(
      (response) async {
        log.finer('_getTokens: ${response.statusCode}');
        if (response.statusCode == 200) {
          _tokens = List.from(json
              .decode(await response.stream.bytesToString())
              .map((item) => Token.fromMap(item)));
          return;
        } else {
          throw ApiException(response.statusCode, info: 'status code other than 200 received');
        }
      },
    );
  }
}
