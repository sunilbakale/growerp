import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../models/@models.dart';
import '../blocs/@bloc.dart';
import '../services/repos.dart';
import '../routing_constants.dart';
import 'changePw_form.dart';
import '../helper_functions.dart';

class LoginArgs {
  final String message; // to show at screen startup
  final String companyPartyId; //if present select if not create company
  final String companyName; // to show onscreen
  const LoginArgs({
    this.message,
    this.companyPartyId,
    this.companyName,
  });
  String toString() =>
      "Message: ${this.message} Company: ${this.companyName}[${this.companyPartyId}]";
}

class LoginForm extends StatelessWidget {
  final LoginArgs loginArgs;
  const LoginForm({this.loginArgs});
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, false);
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(loginArgs?.companyPartyId == null ||
                    loginArgs.companyPartyId == ''
                ? 'Login'
                : loginArgs?.companyPartyId != null &&
                        loginArgs.companyPartyId != ''
                    ? 'Login to ecommerce shop: ${loginArgs.companyName}'
                    : ''),
            actions: <Widget>[
              IconButton(
                  icon: Icon(Icons.home),
                  onPressed: () => Navigator.pushNamed(context, HomeRoute)),
            ],
          ),
          body: BlocProvider(
            create: (context) => LoginBloc(repos: context.repository<Repos>())
              ..add(
                  LoadLogin(loginArgs?.companyPartyId, loginArgs?.companyName)),
            child: LoginHeader(loginArgs?.message),
          ),
        ));
  }
}

class LoginHeader extends StatefulWidget {
  final String message;
  const LoginHeader(this.message);
  @override
  State<LoginHeader> createState() => _LoginHeaderState(message);
}

class _LoginHeaderState extends State<LoginHeader> {
  final String message;
  final _formKey = GlobalKey<FormState>();
  Authenticate authenticate;
  bool _obscureText = true;
  String companyPartyId;
  String companyName;
  List<Company> companies;

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
    final _usernameController = TextEditingController()
      ..text = authenticate?.user?.name != null
          ? authenticate.user.name
          : kReleaseMode ? '' : 'admin@growerp.com';
    Company _companySelected;
    final _passwordController = TextEditingController()
      ..text = kReleaseMode ? '' : 'qqqqqq9!';
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
            bloc: context.bloc<AuthBloc>(),
            listener: (context, state) {
              print("login listen state: ${state.runtimeType}");
              if (state is AuthAuthenticated) Navigator.pop(context, true);
              if (state is AuthConnectionProblem) {
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text('${state.errorMessage}'),
                  backgroundColor: Colors.red,
                ));
              }
            }),
        BlocListener<LoginBloc, LoginState>(listener: (context, state) {
          print("login listen state: ${state.runtimeType}");
          if (state is LoginLoading) {
            HelperFunctions.showMessage(
                context, 'Loading login form...', Colors.green);
          }
          if (state is LogginInProgress) {
            HelperFunctions.showMessage(context, 'Logging in...', Colors.green);
          }
          if (state is LoginError) {
            HelperFunctions.showMessage(
                context, '${state.errorMessage}', Colors.red);
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
      child: BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
        if (state is AuthUnauthenticated) authenticate = state.authenticate;
        return BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
          if (state is LoginLoading)
            return Center(child: CircularProgressIndicator());
          if (state is LoginError)
            return Center(child: Text("Error ${state?.errorMessage}"));
          if (state is LoginLoaded) {
            companyPartyId = state?.companyPartyId;
            companyName = state?.companyName;
            companies = state?.companies;
            _companySelected = companyPartyId != null && companyPartyId != ''
                ? Company(partyId: companyPartyId)
                : companies[0] ?? null;
            print(
                "===login loaded: companyPartyid: $companyPartyId companyName: $companyName");
            return Center(
                child: Container(
                    width: 400,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 40),
                          Visibility(
                              // allow selection of company
                              visible: companyPartyId == null ||
                                  companyPartyId == '',
                              child: Column(children: [
                                Container(
                                  width: 400,
                                  height: 60,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25.0),
                                    border: Border.all(
                                        color: Colors.grey,
                                        style: BorderStyle.solid,
                                        width: 0.80),
                                  ),
                                  child: DropdownButton(
                                    key: ValueKey('drop_down'),
                                    underline: SizedBox(), // remove underline
                                    hint: Text('Company'),
                                    value: _companySelected,
                                    items: companies?.map((item) {
                                      return DropdownMenuItem<Company>(
                                        child: Text(item?.name ?? 'Company??'),
                                        value: item,
                                      );
                                    })?.toList(),
                                    onChanged: (Company newValue) {
                                      setState(() {
                                        _companySelected = newValue;
                                      });
                                    },
                                    isExpanded: true,
                                  ),
                                ),
                                SizedBox(height: 20),
                              ])),
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
                                    state is! LogginInProgress)
                                  BlocProvider.of<LoginBloc>(context).add(
                                      LoginButtonPressed(
                                          companyPartyId:
                                              _companySelected.partyId,
                                          username: _usernameController.text,
                                          password: _passwordController.text));
                              }),
                          SizedBox(height: 30),
                          GestureDetector(
                            child: Text('register new account'),
                            onTap: () async {
                              print(
                                  "====login partyname to register: $companyName");
                              final dynamic result = await Navigator.pushNamed(
                                  context, RegisterRoute,
                                  arguments: LoginArgs(
                                      companyPartyId: companyPartyId,
                                      companyName: companyName));
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
                            child: state is LogginInProgress
                                ? CircularProgressIndicator()
                                : null,
                          ),
                        ],
                      ),
                    )));
          }
          return Container();
        });
      }),
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
