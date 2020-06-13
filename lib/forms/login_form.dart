import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../models/@models.dart';
import '../bloc/@bloc.dart';
import '../services/repos.dart';

class LoginForm extends StatelessWidget {
  final Repos repos;
  final Authenticate authenticate;

  LoginForm({Key key, @required this.repos, this.authenticate})
      : assert(repos != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.home),
              onPressed: () =>
                  BlocProvider.of<AuthBloc>(context).add(AppStarted())),
        ],
      ),
      body: BlocProvider(
        create: (context) {
          return LoginBloc(
            authBloc: BlocProvider.of<AuthBloc>(context),
            repos: repos,
          );
        },
        child: LoginEntry(authenticate: authenticate),
      ),
    );
  }
}

class LoginEntry extends StatefulWidget {
  final Authenticate authenticate;

  const LoginEntry({Key key, this.authenticate}) : super(key: key);
  @override
  State<LoginEntry> createState() => _LoginEntryState(authenticate);
}

class _LoginEntryState extends State<LoginEntry> {
  final _formKey = GlobalKey<FormState>();
  final Authenticate authenticate;
  bool _obscureText = true;
  _LoginEntryState(this.authenticate);

  @override
  Widget build(BuildContext context) {
    final _usernameController = TextEditingController()
      ..text = authenticate?.user?.name == null || kReleaseMode
          ? 'admin@growerp.com'
          : authenticate?.user?.name;
    final _passwordController = TextEditingController()
      ..text = kReleaseMode ? '' : 'qqqqqq9!';

    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginFailure) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text('${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          return Center(
              // login screen
              child: SizedBox(
                  width: 400,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 40),
                        TextFormField(
                          decoration: InputDecoration(labelText: 'username'),
                          controller: _usernameController,
                          validator: (value) {
                            if (value.isEmpty)
                              return 'Please enter username or email?';
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                            validator: (value) {
                              if (value.isEmpty)
                                return 'Please enter your password?';
                              return null;
                            },
                            controller: _passwordController,
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              helperText:
                                  'At least 8 characters, including alpha, number & special character.',
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                                child: Icon(_obscureText
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                              ),
                            )),
                        SizedBox(height: 20),
                        RaisedButton(
                            child: Text('Login'),
                            onPressed: () {
                              if (_formKey.currentState.validate() &&
                                  state is! LoginInProgress)
                                BlocProvider.of<LoginBloc>(context).add(
                                  LoginButtonPressed(
                                    username: _usernameController.text,
                                    password: _passwordController.text,
                                  ),
                                );
                            }),
                        SizedBox(height: 30),
                        GestureDetector(
                            child: Text(
                              'register new account',
                            ),
                            onTap: () {
                              BlocProvider.of<AuthBloc>(context)
                                  .add(Register());
                            }),
                        SizedBox(height: 30),
                        GestureDetector(
                            child: Text(
                              'forgot password?',
                            ),
                            onTap: () async {
                              final String username =
                                  await _sendResetPasswordDialog(
                                      context, authenticate?.user?.name);
                              if (username != null) {
                                BlocProvider.of<AuthBloc>(context)
                                    .add(ResetPassword(username: username));
                              }
                            }),
                        Container(
                          child: state is LoginInProgress
                              ? CircularProgressIndicator()
                              : null,
                        ),
                      ],
                    ),
                  )));
        },
      ),
    );
  }
}

_sendResetPasswordDialog(BuildContext context, String username) async {
  return showDialog<String>(
    context: context,
    barrierDismissible:
        false, // dialog is dismissible with a tap on the barrier
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0))),
        title: Text(
            'Email you registered with?\nWe will send you a reset password',
            textAlign: TextAlign.center),
        content: new Row(children: <Widget>[
          new Expanded(
              child: TextFormField(
                  initialValue: username,
                  autofocus: true,
                  decoration: new InputDecoration(labelText: 'Email:'),
                  onChanged: (value) {
                    username = value;
                  }))
        ]),
        actions: <Widget>[
          FlatButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(null);
            },
          ),
          FlatButton(
            child: Text('Ok'),
            onPressed: () {
              Navigator.of(context).pop(username);
            },
          ),
        ],
      );
    },
  );
}
