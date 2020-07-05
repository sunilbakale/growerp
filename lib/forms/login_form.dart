import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../models/@models.dart';
import '../bloc/@bloc.dart';
import '../services/repos.dart';
import '../routing_constants.dart';
import 'changePw_form.dart';
import '../helper_functions.dart';

class LoginForm extends StatelessWidget {
  final String message;
  const LoginForm({Key key, this.message}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, false);
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text('Login'),
          ),
          body: BlocProvider(
            create: (context) => LoginBloc(repos: context.repository<Repos>()),
            child: LoginHeader(),
          ),
        ));
  }
}

class LoginHeader extends StatefulWidget {
  final String message;

  const LoginHeader({Key key, this.message}) : super(key: key);
  @override
  State<LoginHeader> createState() => _LoginHeaderState(message);
}

class _LoginHeaderState extends State<LoginHeader> {
  final String message;
  final _formKey = GlobalKey<FormState>();
  Authenticate authenticate;
  bool _obscureText = true;

  _LoginHeaderState(this.message);

  @override
  void initState() {
    Future<Null>.delayed(Duration(milliseconds: 0), () {
      if (message != null)
        HelperFunctions.showMessage(context, '$message', Colors.green);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
            bloc: context.bloc<AuthBloc>(),
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                Navigator.pop(context, true);
              }
              if (state is AuthConnectionProblem) {
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text('${state.errorMessage}'),
                  backgroundColor: Colors.red,
                ));
              }
            }),
        BlocListener<LoginBloc, LoginState>(listener: (context, state) {
          if (state is LoginFailure) {
            HelperFunctions.showMessage(context, '${state.error}', Colors.red);
          }
          if (state is LoginChangePw) {
            Navigator.pushNamed(context, ChangePwRoute,
                arguments: ChangePwArgs(state.username, state.password));
          }
          if (state is LoginOk) {
            BlocProvider.of<AuthBloc>(context)
                .add(LoggedIn(authenticate: state.authenticate));
          }
        }),
      ],
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          final _usernameController = TextEditingController()
            ..text = authenticate?.user?.name == null || kReleaseMode
                ? 'admin@growerp.com'
                : authenticate?.user?.name;
          final _passwordController = TextEditingController()
            ..text = kReleaseMode ? '' : 'qqqqqq9!';
          return Center(
              child: SizedBox(
                  width: 400,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 40),
                        TextFormField(
                          key: Key('username'),
                          decoration: InputDecoration(labelText: 'Username'),
                          controller: _usernameController,
                          validator: (value) {
                            if (value.isEmpty)
                              return 'Please enter username or email?';
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                            key: Key('password'),
                            validator: (value) {
                              if (value.isEmpty)
                                return 'Please enter your password?';
                              return null;
                            },
                            controller: _passwordController,
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              labelText: 'Password',
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
                                        password: _passwordController.text));
                            }),
                        SizedBox(height: 30),
                        GestureDetector(
                          child: Text('register new account'),
                          onTap: () async {
                            final dynamic result = await Navigator.pushNamed(
                                context, RegisterRoute);
                            HelperFunctions.showMessage(
                                context, '$result', Colors.green);
                          },
                        ),
                        SizedBox(height: 30),
                        GestureDetector(
                            child: Text('forgot password?'),
                            onTap: () async {
                              final String username =
                                  await _sendResetPasswordDialog(
                                      context,
                                      authenticate?.user?.name == null ||
                                              kReleaseMode
                                          ? 'admin@growerp.com'
                                          : authenticate?.user?.name);
                              if (username != null) {
                                BlocProvider.of<AuthBloc>(context)
                                    .add(ResetPassword(username: username));
                                HelperFunctions.showMessage(
                                    context,
                                    'An email with password has been send to $username',
                                    Colors.green);
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
