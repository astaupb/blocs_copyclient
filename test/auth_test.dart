@TestOn("vm")
import 'package:blocs_copyclient/auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import 'backend_shiva.dart';

const String username = 'test';
const String password = 'test123';

void main() {
  AuthBloc bloc;

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  setUp(() {
    bloc = AuthBloc(backend: BackendShiva(http.Client()));
  });

  test('test logging in', () {
    bloc.listen(expectAsync1((AuthState state) {
      if (state.isAuthorized) {
        print('successfully authorized');
      }
    }, count: 3));

    bloc.onLogin(username, password);
  });

  tearDown(() {
    bloc.close();
  });
}
