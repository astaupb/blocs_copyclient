import 'package:blocs_copyclient/blocs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import 'backend_sunrise.dart';
import 'login_form.dart';

void main() => runApp(CopyclientDemo());

class CopyclientDemo extends StatelessWidget {
  static final http.Client client = http.Client();

  final AuthBloc authBloc = AuthBloc(backend: BackendSunrise(client));

  CopyclientDemo() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      print(
          '[${record.loggerName}] (${record.level.name}) ${record.time}: ${record.message}');
    });
    Logger('Copyclient').info('Copyclient Example started');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider<AuthBloc>(
        bloc: authBloc,
        child: MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState();

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: BlocBuilder(
        bloc: BlocProvider.of<AuthBloc>(context),
        builder: (BuildContext context, AuthState state) {
          if (state.isUnauthorized) {
            return new LoginForm();
          } else if (state.isBusy) {
            return Center(child: CircularProgressIndicator());
          } else if (state.isAuthorized) {
            // AUTHORIZED AND READY TO HUSTLE
            return Text(state.toString());
          }
        },
      ),
      floatingActionButton: Builder(
        builder: (BuildContext context) => FloatingActionButton(
              onPressed: () => Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          BlocProvider.of<AuthBloc>(context).backend.host),
                    ),
                  ),
            ),
      ),
    );
  }
}
