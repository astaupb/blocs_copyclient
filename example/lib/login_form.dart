import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blocs_copyclient/auth.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({
    Key key,
  }) : super(key: key);

  @override
  LoginFormState createState() {
    return LoginFormState();
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
            child: Text('Login'),
            onPressed: () => BlocProvider.of<AuthBloc>(context)
                .onLogin(usernameController.text, passwordController.text),
          ),
        ],
      ),
    );
  }
}
