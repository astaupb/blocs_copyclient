import 'package:blocs_copyclient/blocs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import 'backend_shiva.dart';
import 'jobs_page.dart';
import 'login_page.dart';

void main() => runApp(CopyclientDemo());

final routes = {
  '/login': (BuildContext context) => LoginPage(),
  '/': (BuildContext context) => HomePage(),
  '/jobs': (BuildContext context) => JobsPage(),
};

class CopyclientDemo extends StatelessWidget {
  CopyclientDemo() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      print('[${record.loggerName}] (${record.level.name}) ${record.time}: ${record.message}');
    });
    Logger('Copyclient').info('Copyclient Example started');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Copyclient Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: routes,
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static final http.Client client = http.Client();
  static final Backend backend = BackendShiva(client);

  AuthBloc authBloc = AuthBloc(backend: backend);
  JoblistBloc jobsBloc = JoblistBloc(backend);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => authBloc,
      child: BlocBuilder(
        bloc: authBloc,
        builder: (BuildContext context, AuthState state) {
          if (state.isUnauthorized) {
            return LoginPage();
          } else if (state.isBusy) {
            return Center(child: CircularProgressIndicator());
          } else if (state.isAuthorized) {
            // AUTHORIZED AND READY TO HUSTLE
            jobsBloc.onStart(state.token);
            return BlocProvider<JoblistBloc>(
              create: (_) => jobsBloc,
              child: JobsPage(),
            );
          }
          return Container(width: 0.0, height: 0.0);
        },
      ),
    );
  }

  @override
  void dispose() {
    authBloc.close();
    jobsBloc.close();
    super.dispose();
  }
}
