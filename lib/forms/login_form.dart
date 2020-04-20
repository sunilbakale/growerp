import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import '../services/repos.dart';
import '../bloc/bloc.dart';
import '../widgets/widgets.dart';

class LoginForm extends StatefulWidget {
  final Repos repos;
  final AuthBloc authBloc;

  LoginForm(
      {Key key,
      @required this.repos,
      @required this.authBloc})
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
      create: (context) => LoginBloc(
          authBloc: BlocProvider.of<AuthBloc>(context),
          repos: repos),
      child: BlocBuilder<LoginBloc, FormBlocState>(
        condition: (previous, current) =>
            previous.runtimeType != current.runtimeType ||
            previous is FormBlocLoading && current is FormBlocLoading,
        builder: (context, state) {
          if (state is FormBlocLoading) {
            return Center(child: CircularProgressIndicator());
          } else {
            final loginFormBloc = context.bloc<LoginBloc>();
            return Scaffold(
              resizeToAvoidBottomInset: false,
              body: FormBlocListener<LoginBloc, String, String>(
                onSubmitting: (context, state) {
                  LoadingIndicator();
                },
                onSuccess: (context, state) =>
                  BlocProvider.of<AuthBloc>(context)
                      .add(AppStarted()),
//                  Navigator.of(context).popAndPushNamed('/home');
//                  Notifications.showSnackBarWithSuccess(
//                      context, ' successfully logged in.');
//                },
                onFailure: (context, state) {
                  Scaffold.of(context).showSnackBar(
                      SnackBar(content: Text(state.failureResponse)));
                },
                child: Center(
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 40),
                      Image.asset('assets/growerp.png', height: 100),
                      Text(
                        loginFormBloc?.authenticate?.company?.name == null
                            ? 'Hotel'
                            : loginFormBloc?.authenticate?.company?.name,
                        style: TextStyle(
                            color: Color(0xFFB52727),
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      TextFieldBlocBuilder(
                        textFieldBloc: loginFormBloc.email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                        nextFocusNode: _focusNodes[0],
                      ),
                      TextFieldBlocBuilder(
                        textFieldBloc: loginFormBloc.password,
                        suffixButton: SuffixButton.obscureText,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                        ),
                        focusNode: _focusNodes[0],
                      ),
                      SizedBox(height: 20),
                      RaisedButton(
                        onPressed: loginFormBloc.submit,
                        child: Text('LOGIN'),
                      ),
                      RaisedButton(
                        onPressed: () =>
                            BlocProvider.of<AuthBloc>(context)
                              .add(Register()),
                        child: Text('register new account'),
                      ),
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
