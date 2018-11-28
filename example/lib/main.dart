import 'package:blocs_copyclient/blocs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:barcode_scan/barcode_scan.dart';

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

  static final http.Client client = http.Client();

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  JobsBloc jobsBloc;

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
            jobsBloc = JobsBloc(BackendSunrise(client), state.token);
            return BlocProvider<JobsBloc>(
              bloc: jobsBloc,
              child: BlocBuilder(
                bloc: jobsBloc,
                builder: (BuildContext context, JobsState state) {
                  if (state.isInit) {
                    return Column(children: <Widget>[
                      Text('Jobliste gestartet!'),
                      RaisedButton(
                        onPressed: () => jobsBloc.onStart(),
                        child: Text('Jobliste laden'),
                      )
                    ]);
                  } else if (state.isBusy) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state.isResult) {
                    return ListView.builder(
                      itemCount: state.value.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(state.value[index].jobInfo.filename),
                          onTap: () async {
                            try {
                              String target = await BarcodeScanner.scan();
                              jobsBloc.onPrint(target, index);
                            } catch (e) {
                              print('Jobs: $e');
                              Scaffold.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                      'Es wurde kein Drucker ausgewählt')));
                            }
                          },
                        );
                      },
                    );
                  } else if (state.isError) {
                    return Text('Ein Fehler ist aufgetreten: ${state.err}');
                  }
                },
              ),
            );
          }
        },
      ),
      floatingActionButton: Builder(
        builder: (BuildContext context) => FloatingActionButton(
              onPressed: () => Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text(BlocProvider.of<AuthBloc>(context).backend.host),
                    ),
                  ),
            ),
      ),
    );
  }
}
