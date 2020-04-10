import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import '../services/user_repository.dart';
import '../bloc/login_form_bloc.dart';
import '../bloc/authentication/authentication.dart';
import '../widgets/widgets.dart';

class LoginForm extends StatefulWidget {
  final UserRepository userRepository;

  LoginForm({Key key, @required this.userRepository})
    : assert(userRepository != null),
      super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState(userRepository);
}
class _LoginFormState extends State<LoginForm> {
  final UserRepository userRepository;

  LoginFormBloc _formBloc;
  List<FocusNode> _focusNodes;

  _LoginFormState(this.userRepository);

  @override
  void initState() {
    _formBloc = LoginFormBloc(
      authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
      userRepository: userRepository);
    _focusNodes = [FocusNode()];
    super.initState();
  }

  @override
  void dispose() {
    _formBloc.close();
    _focusNodes.forEach((focusNode) => focusNode.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginFormBloc(
        authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
        userRepository: userRepository),
      child: Builder(
        builder: (context) {
          final loginFormBloc = context.bloc<LoginFormBloc>();
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: FormBlocListener<LoginFormBloc, String, String>(
              onSubmitting: (context, state) {
                LoadingIndicator();
              },
              onFailure: (context, state) {
                Scaffold.of(context).showSnackBar(
                    SnackBar(content: Text(state.failureResponse)));
              },
              child: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 40),
                    Image.asset('assets/growerp.png', height: 100),
                    Text(
                      'Hotel',
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
                      textInputAction: TextInputAction.done,
                      suffixButton: SuffixButton.obscureText,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      focusNode: _focusNodes[0],
                    ),
                    RaisedButton(
                      onPressed: loginFormBloc.submit,
                      child: Text('LOGIN'),
                    ),
                    RaisedButton(
                      onPressed: () => 
                        Navigator.of(context).pushNamed('/register'),
                      child: Text('register new account'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
