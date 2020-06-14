import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../models/@models.dart';
import '../bloc/@bloc.dart';
import '../services/repos.dart';

class ChangePwForm extends StatelessWidget {
  final String username;
  final String oldPassword;
  final Repos repos;
  final Authenticate authenticate;

  ChangePwForm(
      {Key key,
      @required this.repos,
      this.authenticate,
      this.username,
      this.oldPassword})
      : assert(repos != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    print("====pw form: $username");
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.home),
              onPressed: () =>
                  BlocProvider.of<AuthBloc>(context).add(AppStarted())),
        ],
      ),
      body: BlocProvider(
        create: (context) {
          return ChangePwBloc(
            authBloc: BlocProvider.of<AuthBloc>(context),
            repos: repos,
          );
        },
        child: ChangePwEntry(
          authenticate: authenticate,
          username: username,
          oldPassword: oldPassword,
        ),
      ),
    );
  }
}

class ChangePwEntry extends StatefulWidget {
  final String username;
  final String oldPassword;
  final Authenticate authenticate;

  const ChangePwEntry(
      {Key key, this.username, this.oldPassword, this.authenticate})
      : super(key: key);
  @override
  State<ChangePwEntry> createState() =>
      _ChangePwEntryState(username, oldPassword, authenticate);
}

class _ChangePwEntryState extends State<ChangePwEntry> {
  final String username;
  final String oldPassword;
  final Authenticate authenticate;
  final _formKey = GlobalKey<FormState>();
  bool _obscureText1 = true;
  bool _obscureText2 = true;
  final _password1Controller = TextEditingController();
  final _password2Controller = TextEditingController();

  _ChangePwEntryState(this.username, this.oldPassword, this.authenticate);

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChangePwBloc, ChangePwState>(
      listener: (context, state) {
        if (state is ChangePwFailed) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text('${state.msg}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<ChangePwBloc, ChangePwState>(
        builder: (context, state) {
          return Scaffold(
              body: Center(
                  child: SizedBox(
                      width: 400,
                      child: Form(
                        key: _formKey,
                        child: Column(children: <Widget>[
                          SizedBox(height: 40),
                          Text('You entered the correct temporary password\n'),
                          Text('Now enter a new password.\n'),
                          SizedBox(height: 20),
                          Text("username: $username"),
                          SizedBox(height: 20),
                          TextFormField(
                            autofocus: true,
                            controller: _password1Controller,
                            obscureText: _obscureText1,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              helperText:
                                  'At least 8 characters, including alpha, number & special character.',
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _obscureText1 = !_obscureText1;
                                  });
                                },
                                child: Icon(_obscureText1
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                              ),
                            ),
                            validator: (value) {
                              if (value.isEmpty)
                                return 'Please enter first password?';
                              final regExpRequire = RegExp(
                                  r'^(?=.*[0-9])(?=.*[a-zA-Z])(?=.*[!@#$%^&+=]).{8,}');
                              if (!regExpRequire.hasMatch(value))
                                return 'At least 8 characters, including alpha, number & special character.';
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            obscureText: _obscureText2,
                            decoration: InputDecoration(
                              labelText: 'Verify Password',
                              helperText: 'Enter the new password again.',
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _obscureText2 = !_obscureText2;
                                  });
                                },
                                child: Icon(_obscureText2
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                              ),
                            ),
                            controller: _password2Controller,
                            validator: (value) {
                              if (value.isEmpty)
                                return 'Enter password again to verify?';
                              if (value != _password1Controller.text)
                                return 'Password is not matching';
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          RaisedButton(
                              child: Text('Submit new Password'),
                              onPressed: () {
                                print("change password current state: $state");
                                if (_formKey.currentState.validate() &&
                                    state is ChangePwInitial)
                                  BlocProvider.of<ChangePwBloc>(context).add(
                                    ChangePwButtonPressed(
                                      username: username,
                                      oldPassword: oldPassword,
                                      newPassword: _password1Controller.text,
                                    ),
                                  );
                              }),
                        ]),
                      ))));
        },
      ),
    );
  }
}
