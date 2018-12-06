import 'package:blocs_copyclient/blocs.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'login_form.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  _LoginPageState();

  static final http.Client client = http.Client();

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  JoblistBloc jobsBloc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: LoginForm(),
    );
  }
}
