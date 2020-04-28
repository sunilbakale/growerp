import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import '../services/repos.dart';
import '../bloc/bloc.dart';
import '../widgets/widgets.dart';

class LoginForm extends StatefulWidget {
  final Repos repos;
  final AuthBloc authBloc;

  LoginForm({Key key, @required this.repos, @required this.authBloc})
      : assert(repos != null, authBloc != null);

  @override
  _LoginState createState() => _LoginState(repos, authBloc);
}

class _LoginState extends State<LoginForm> {
  final Repos repos;
  final AuthBloc authBloc;

  List<FocusNode> _focusNodes;

  _LoginState(this.repos, this.authBloc);

  @override
  void initState() {
    _focusNodes = [FocusNode()];
    super.initState();
  }

  @override
  void dispose() {
    _focusNodes.forEach((focusNode) => focusNode.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          LoginBloc(authBloc: BlocProvider.of<AuthBloc>(context), repos: repos),
      child: BlocBuilder<LoginBloc, FormBlocState>(
        condition: (previous, current) =>
            previous.runtimeType != current.runtimeType ||
            previous is FormBlocLoading && current is FormBlocLoading,
        builder: (context, state) {
          if (state is FormBlocLoading) {
            return Center(child: CircularProgressIndicator());
          } else {
            final loginBloc = context.bloc<LoginBloc>();
            return Scaffold(
              resizeToAvoidBottomInset: false,
              body: FormBlocListener<LoginBloc, String, String>(
                onSubmitting: (context, state) {
                  LoadingDialog.show(context);
                },
                onSuccess: (context, state) {
                  LoadingDialog.hide(context);
                  print("===success response: ${state.successResponse}");
                    BlocProvider.of<AuthBloc>(context)
                      .add(LoggedIn(authenticate: loginBloc.authenticate));
                },
                onFailure: (context, state) {
                  LoadingDialog.hide(context);
                  Scaffold.of(context).showSnackBar(
                      SnackBar(content: Text(state.failureResponse)));
                },
                child: Center(
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 40),
                      Image.asset('assets/growerp.png', height: 100),
                      Text(
                        loginBloc?.authenticate?.company?.name == null
                            ? 'Hotel'
                            : loginBloc?.authenticate?.company?.name,
                        style: TextStyle(
                            color: Color(0xFFB52727),
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      TextFieldBlocBuilder(
                        textFieldBloc: loginBloc.email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                        nextFocusNode: _focusNodes[0],
                      ),
                      TextFieldBlocBuilder(
                        textFieldBloc: loginBloc.password,
                        suffixButton: SuffixButton.obscureText,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                        ),
                        focusNode: _focusNodes[0],
                      ),
                      SizedBox(height: 20),
                      RaisedButton(
                        onPressed: loginBloc.submit,
                        child: Text('LOGIN'),
                      ),
                      SizedBox(height: 30),
                      GestureDetector(
                          child: Text(
                            'register new account',
                          ),
                          onTap: () {
                            BlocProvider.of<AuthBloc>(context).add(Register());
                          }),
                      SizedBox(height: 30),
                      GestureDetector(
                          child: Text(
                            'forgot password?',
                          ),
                          onTap: () async {
                            final String username = await _newPasswordDialog(
                                context, loginBloc.authenticate?.user?.name);
                            if (username != null) {
                              BlocProvider.of<AuthBloc>(context).add(
                                  ResetPassword(
                                      username: username));
                            }
                          })
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

_newPasswordDialog(BuildContext context, String username) async {
  return showDialog<String>(
    context: context,
    barrierDismissible:
        false, // dialog is dismissible with a tap on the barrier
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Email you registered with?\nWe will send you a reset password',
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
