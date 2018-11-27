import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blocs_copyclient/auth.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({
    Key key,
  }) : super(key: key);

  @override
  LoginFormState createState() {
    return new LoginFormState();
  }
}

class LoginFormState extends State<LoginForm> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      child: ListView(
        children: <Widget>[
          Text('Login:'),
          TextFormField(
            autocorrect: false,
            controller: usernameController,
          ),
          TextFormField(
            autocorrect: false,
            controller: passwordController,
            obscureText: true,
          ),
          RaisedButton(
            onPressed: () => BlocProvider.of<AuthBloc>(context).login(
                usernameController.text, passwordController.text),
          ),
        ],
      ),
    );
  }
}
