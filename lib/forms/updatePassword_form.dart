import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import '../services/repos.dart';
import '../bloc/bloc.dart';
import '../widgets/widgets.dart';

class UpdatePasswordForm extends StatefulWidget {
  final Repos repos;
  final AuthBloc authBloc;
  final String username, password;

  UpdatePasswordForm(
      {Key key,
      @required this.repos, @required this.authBloc,
      @required this.username, @required this.password})
      : assert(repos != null, authBloc != null),
        assert(password != null, username != null);

  @override
  _UpdatePasswordState createState() =>
      _UpdatePasswordState(repos, authBloc, username, password);
}

class _UpdatePasswordState extends State<UpdatePasswordForm> {
  final Repos repos;
  final AuthBloc authBloc;
  String username, password;

  List<FocusNode> _focusNodes;

  _UpdatePasswordState(this.repos, this.authBloc, this.username, this.password);

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
      create: (context) => UpdatePasswordBloc(
          repos: repos, authBloc: BlocProvider.of<AuthBloc>(context),
          username: username, password: password),
      child: BlocBuilder<UpdatePasswordBloc, FormBlocState>(
          builder: (context, state) {
        final updatePasswordBloc = context.bloc<UpdatePasswordBloc>();
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: FormBlocListener<UpdatePasswordBloc, String, String>(
            onSubmitting: (context, state) {
              LoadingDialog.show(context);
            },
            onSuccess: (context, state) {
              LoadingDialog.hide(context);
              BlocProvider.of<AuthBloc>(context).add(AppStarted());
            },
            onFailure: (context, state) {
              LoadingDialog.hide(context);
              Scaffold.of(context)
                .showSnackBar(SnackBar(content: Text(state.failureResponse)));
            },
            child: Center(
              child: Column(
                children: <Widget>[
                  SizedBox(height: 60),
                  Text(
                    'Change password for\n${updatePasswordBloc.username}',
                    style: TextStyle(fontSize: 20, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  TextFieldBlocBuilder(
                    textFieldBloc: updatePasswordBloc.newPassword,
                    suffixButton: SuffixButton.obscureText,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    nextFocusNode: _focusNodes[0],
                  ),
                  TextFieldBlocBuilder(
                    textFieldBloc: updatePasswordBloc.confirmPassword,
                    suffixButton: SuffixButton.obscureText,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    focusNode: _focusNodes[0],
                  ),
                  SizedBox(height: 20),
                  RaisedButton(
                    onPressed: updatePasswordBloc.submit,
                    child: Text('Update password'),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
