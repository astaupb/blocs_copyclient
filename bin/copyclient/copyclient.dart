import 'dart:async';
import 'dart:io';

import 'package:blocs_copyclient/blocs.dart';
import 'package:logging/logging.dart';

class Copyclient {
  AuthBloc authBloc;
  UserBloc userBloc;
  JoblistBloc joblistBloc;
  JournalBloc journalBloc;
  UploadBloc uploadBloc;
  PrintQueueBloc printQueueBloc;
  File logFile = File('.copyclient_cli.log');

  int _tokenId;
  String _token;

  int get tokenId => _tokenId;
  String get token => _token;

  bool authorized = false;

  Copyclient(Backend backend) {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      logFile.writeAsString('[${record.loggerName}] ${record.message}', mode: FileMode.append);
    });

    authBloc = AuthBloc(backend: backend);
    userBloc = UserBloc(backend);
    uploadBloc = UploadBloc(backend);
    joblistBloc = JoblistBloc(backend);
    journalBloc = JournalBloc(backend);
    printQueueBloc = PrintQueueBloc(backend);

    authBloc.listen((AuthState state) {
      if (state.isAuthorized) {
        authorized = true;
        propagateToken(state.token);
      }
      if (state.isUnauthorized && !state.isInit) {
        if (authorized) exit(0);
      }
    });
  }

  Future<void> login({String username, String password}) async {
    if (username == null && password == null) {
      username = promptFor('username');
      password = promptFor('password');
      authBloc.onLogin(username, password);
    } else if (username == null) {
      authBloc.onTokenLogin(password);
    } else {
      authBloc.onLogin(username, password);
    }
  }

  Future<void> showJobs() async {
    var listener;
    listener = joblistBloc.listen(
      (JoblistState state) {
        if (state.isResult)
          state.value.forEach((Job job) {
            print('${job.id}: ${job.jobInfo.filename}, Pages: ${job.jobInfo.pagecount}');
          });
        listener.cancel();
      },
    );
  }

  Future<void> showJobDetails(int id) async {
    var listener;
    joblistBloc.onRefreshOptions(id);
    listener = joblistBloc.listen((JoblistState state) {
      if (state.isResult) {
        print(state.value[joblistBloc.getIndexById(id)]);
        listener.cancel();
      }
    });
  }

  Future<void> updatePageRange(int id, String range) {
    var listener;
    final index = joblistBloc.getIndexById(id);
    var options = joblistBloc.jobs[index].jobOptions;
    options.range = range;
    joblistBloc.onUpdateOptionsById(id, options);
    listener = joblistBloc.listen((JoblistState state) {
      if (state.isResult) {
        showJobDetails(id);
        listener.cancel();
      }
    });
    return null;
  }

  String promptFor(String prompt) {
    stdout.write('$prompt: ');
    return stdin.readLineSync();
  }

  void propagateToken(String token) {
    _token = token;
    userBloc.onStart(token);
    joblistBloc.onStart(token);
    journalBloc.onStart(token);
    uploadBloc.onStart(token);
    printQueueBloc.onStart(token);
  }

  Future<void> upload(String path) async {
    var split = path.split('/');
    var filename = split[split.length - 1];
    var file = await File(path).open();
    var data = file.readSync(1000000000);
    uploadBloc.onUpload(data, filename: filename);
  }
}
