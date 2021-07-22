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

  TokensBloc(this._backend) : super(TokensState.init()) {
    log.fine('$this started');
  }

  @override
  Stream<TokensState> mapEventToState(TokensEvent event) async* {
    log.fine('Event: $event');
    yield TokensState.busy();

    if (event is InitTokens) {
      _token = event.token;
      yield TokensState.init();
    } else if (event is GetTokens) {
      try {
        await _getTokens();
        yield TokensState.result(_tokens);
      } on ApiException catch (e) {
        yield TokensState.exception(e);
      }
    } else if (event is DeleteToken) {
      try {
        await _deleteToken(event.id);
        yield TokensState.result(_tokens);
      } on ApiException catch (e) {
        yield TokensState.exception(e);
      }
    } else if (event is DeleteTokens) {
      try {
        await _deleteTokens();
        await _getTokens();
        yield TokensState.result(_tokens);
      } on ApiException catch (e) {
        yield TokensState.exception(e);
      }
    }
  }

  void onDeleteToken(int id) => this.add(DeleteToken(id));

  void onDeleteTokens() => this.add(DeleteTokens());

  void onGetTokens() => this.add(GetTokens());

  void onStart(String token) => this.add(InitTokens(token));

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

  Future<void> _deleteTokens() async {
    Request request = ApiRequest('DELETE', '/user/tokens', _backend);
    request.headers['X-Api-Key'] = _token;

    log.finer('_deleteTokens: $request');

    return await _backend.send(request).then(
      (response) async {
        log.finer('_deleteTokens: ${response.statusCode}');
        if (response.statusCode == 205) {
          _tokens = [];
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
        log.finer('_getTokens: ${response.statusCode} on ${response.request}');

        if (response.statusCode == 200) {
          _tokens =
              List.from(await response.stream.bytesToString().then<Iterable<Token>>((String raw) {
            log.finest('_getTokens: raw response $raw');

            Iterable j = json.decode(raw);
            log.finest('_getTokens: decoded json: $j');

            return j.map<Token>(
              (item) {
                Token temp = Token.fromMap(item);
                log.finest('_getTokens: parsed Token object $temp');
                temp.clientType = _parseClientType(temp.userAgent);
                return temp;
              },
            );
          }));
          return;
        } else {
          throw ApiException(response.statusCode, info: 'status code other than 200 received');
        }
      },
    );
  }

  ClientType _parseClientType(String userAgent) {
    if (userAgent.contains('(dart:io)')) {
      return ClientType.dartio;
    } else if (userAgent.contains('AStACopyclient')) {
      return ClientType.electron;
    } else if (userAgent.contains('Chrome/')) {
      return ClientType.chrome;
    } else if (userAgent.contains('Firefox/') && userAgent.contains('Gecko/')) {
      return ClientType.firefox;
    } else if (userAgent.contains('Safari/')) {
      return ClientType.safari;
    } else if (userAgent.contains('curl/')) {
      return ClientType.curl;
    }

    return ClientType.unknown;
  }
}
