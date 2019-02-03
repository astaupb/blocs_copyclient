import 'dart:io';

import 'package:blocs_copyclient/blocs.dart';
import 'package:logging/logging.dart';

class Copyclient {
  AuthBloc authBloc;
  UserBloc userBloc;
  JoblistBloc joblistBloc;
  JournalBloc journalBloc;
  UploadBloc uploadBloc;

  int tokenId;

  bool authorized = false;

  Copyclient(Backend backend) {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      stderr.write('[${record.loggerName}] ${record.message}');
    });

    authBloc = AuthBloc(backend: backend);
    userBloc = UserBloc(backend);
    uploadBloc = UploadBloc(backend);
    joblistBloc = JoblistBloc(backend);
    journalBloc = JournalBloc(backend);

    authBloc.state.listen((AuthState state) {
      if (state.isAuthorized) {
        authorized = true;
        propagateToken(state.token);
      }
      if (state.isUnauthorized && !state.isInit) {
        if (authorized) exit(0);
      }
    });

    userBloc.state.listen((UserState state) {
      if (state.isResult) {
        tokenId = state.value.tokenId;
        print(state.value);
      }
    });

    uploadBloc.state.listen((UploadState state) {
      if (state.isResult) {
        print(state.value);
      }
    });

    joblistBloc.state.listen((JoblistState state) {
      if (state.isResult) {
        print(state.value);
      }
    });

    journalBloc.state.listen((JournalState state) {
      if (state.isResult) {
        print(state.value);
      }
    });
  }

  Future<void> login({String username, String password}) async {
    if (username == null && password == null) {
      username = prompt_for('username');
      password = prompt_for('password');
      authBloc.login(username, password);
    } else if (username == null) {
      authBloc.tokenLogin(password);
    } else {
      authBloc.login(username, password);
    }
  }

  String prompt_for(String prompt) {
    stdout.write('$prompt: ');
    return stdin.readLineSync();
  }

  void propagateToken(String token) {
    userBloc.onStart(token);
    joblistBloc.onStart(token);
    journalBloc.onStart(token);
    uploadBloc.onStart(token);
  }

  Future<void> upload(String path) async {
    var split = path.split('/');
    var filename = split[split.length - 1];
    var file = await File(path).open();
    var data = file.readSync(1000000000);
    uploadBloc.onUpload(data, filename: filename);
  }
}
