import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import '../bloc/bloc.dart';
import '../services/repos.dart';
import '../widgets/widgets.dart';

class RegisterForm extends StatefulWidget {
  final Repos repos;

  RegisterForm({Key key, @required this.repos})
      : assert(repos != null),
        super(key: key);

  @override
  _RegisterFormState createState() => _RegisterFormState(repos);
}

class _RegisterFormState extends State<RegisterForm> {
  final Repos repos;

  List<FocusNode> _focusNodes;

  _RegisterFormState(this.repos);

  @override
  void initState() {
    _focusNodes = [FocusNode(), FocusNode(), FocusNode()];
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
      create: (context) => RegisterBloc(
          authBloc: BlocProvider.of<AuthBloc>(context), repos: repos),
      child: Builder(
        builder: (context) {
          final registerBloc = context.bloc<RegisterBloc>();
          return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(title: Text('Register new Account')),
            body: FormBlocListener<RegisterBloc, String, String>(
              onSubmitting: (context, state) {
                LoadingDialog.show(context);
              },
              onSuccess: (context, state) {
                LoadingDialog.hide(context);
                BlocProvider.of<AuthBloc>(context).add(AppStarted());
              },
              onFailure: (context, state) {
                LoadingDialog.hide(context);
                Scaffold.of(context).showSnackBar(
                    SnackBar(content: Text(state.failureResponse)));
              },
              child: BlocBuilder<RegisterBloc, FormBlocState>(
                  condition: (previous, current) =>
                      previous.runtimeType != current.runtimeType ||
                      previous is FormBlocLoading && current is FormBlocLoading,
                  builder: (context, state) {
                    if (state is FormBlocLoading) {
                      return Center(child: CircularProgressIndicator());
                    } else if (state is FormBlocLoadFailed) {
                      return Center(
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              Icon(Icons.sentiment_dissatisfied, size: 70),
                              SizedBox(height: 20),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                alignment: Alignment.center,
                                child: Text(
                                  state.failureResponse ??
                                      'An error has occurred please try again later',
                                  style: TextStyle(fontSize: 25),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(height: 20),
                              RaisedButton(
                                onPressed: registerBloc.reload,
                                child: Text('RETRY'),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return SingleChildScrollView(
                        physics: ClampingScrollPhysics(),
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 20),
                            TextFieldBlocBuilder(
                              textFieldBloc: registerBloc.company,
                              decoration: InputDecoration(
                                labelText: 'Company',
                                prefixIcon: Icon(Icons.hotel),
                              ),
                              nextFocusNode: _focusNodes[0],
                            ),
                            DropdownFieldBlocBuilder<String>(
                              selectFieldBloc: registerBloc.currency,
                              showEmptyItem: false,
                              millisecondsForShowDropdownItemsWhenKeyboardIsOpen:
                                  320,
                              itemBuilder: (context, value) => value,
                              decoration: InputDecoration(
                                labelText: 'Currency',
                                prefixIcon: Icon(Icons.attach_money),
                              ),
                              focusNode: _focusNodes[0],
                              nextFocusNode: _focusNodes[1],
                            ),
                            TextFieldBlocBuilder(
                              textFieldBloc: registerBloc.fullName,
                              decoration: InputDecoration(
                                labelText: 'First and Last name',
                                prefixIcon: Icon(Icons.person),
                              ),
                              focusNode: _focusNodes[1],
                              nextFocusNode: _focusNodes[2],
                            ),
                            Text(
                              'Password will be sent by Email!',
                              style: TextStyle(
                                  color: Color(0xFFce5310),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            TextFieldBlocBuilder(
                              textFieldBloc: registerBloc.email,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email),
                              ),
                              focusNode: _focusNodes[2],
                            ),
                            RaisedButton(
                              onPressed: registerBloc.submit,
                              child: Text('REGISTER'),
                            ),
                          ],
                        ),
                      );
                    }
                  }),
            ),
          );
        },
      ),
    );
  }
}
