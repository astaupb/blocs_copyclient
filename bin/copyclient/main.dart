import 'dart:io';

import 'package:cli_repl/cli_repl.dart';
import 'package:http/http.dart';

import './backend.dart';
import './copyclient.dart';

main(List<String> args) async {
  final copyclient = Copyclient(BackendSunrise(Client()));

  switch (args.length) {
    case 1:
      copyclient.login(password: args[0]);
      break;
    case 2:
      copyclient.login(username: args[0], password: args[1]);
      break;
    default:
      copyclient.login();
  }

  var repl = Repl(prompt: 'astaprint >>> \n');

  await for (var x in repl.runAsync()) {
    if (x.trim().isEmpty) continue;
    var args = x.split(' ');
    if (args.length < 1) continue;
    switch (args[0]) {
      case "user":
        await copyclient.userBloc.onRefresh();
        break;
      case "jobs":
        await copyclient.joblistBloc.onRefresh();
        break;
      case "journal":
        await copyclient.journalBloc.onRefresh();
        break;
      case "upload":
        if (args.length == 2) {
          await copyclient.upload(args[1]);
        } else {
          copyclient.uploadBloc.onRefresh();
        }
        break;
      case "printer":
        if (args.length == 2) {
          int id = int.tryParse(args[1]);
          if (id != null) {
            copyclient.printQueueBloc.onRefresh(deviceId: id);
          } else {
            stdout.write("pass valid deviceId");
          }
        } else {
          stdout.write("pass deviceId\n");
        }
        break;
      case "exit":
        await copyclient.authBloc.deleteToken();
        break;
      default:
        stdout.write('command not found\n');
    }
  }
}
