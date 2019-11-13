@TestOn("vm")
import 'package:blocs_copyclient/auth.dart';
import 'package:blocs_copyclient/tokens.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import 'backend_shiva.dart';
import 'example_data.dart';

void main() {
  AuthBloc authBloc;
  TokensBloc bloc;

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print(
        '${rec.loggerName} ${rec.level.name}: ${rec.time.toString().split('.').first}: ${rec.message}');
  });

  setUpAll(() async {
    bloc = TokensBloc(BackendShiva(http.Client()));
    authBloc = AuthBloc(backend: BackendShiva(http.Client()));
    authBloc.onLogin(username, password);
    await authBloc.takeWhile((state) => state.isAuthorized != true).toList();
    bloc.onStart(authBloc.state.token);
    await bloc.takeWhile((state) => state.isInit != true).toList();
  });

  test('test getting tokens', () {
    bloc.listen(expectAsync1((TokensState state) {
      if (state.isInit) {
        print('TokensBloc initialized');
      } else if (state.isBusy) {
        print('tokens loading...');
      } else if (state.isResult) {
        print('got tokens: ${state.value}');
      } else if (state.isException) {
        fail('exception: ${state.error}');
      }
    }, count: 3));

    bloc.onGetTokens();
  });

  tearDownAll(() {
    authBloc.onLogout();
    authBloc.close();
    bloc.close();
  });
}
