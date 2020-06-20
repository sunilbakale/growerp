import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../bloc/@bloc.dart';
import '../services/repos.dart';

class RegisterForm extends StatelessWidget {
  final Repos repos;

  RegisterForm({Key key, @required this.repos})
      : assert(repos != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.home),
              onPressed: () =>
                  BlocProvider.of<AuthBloc>(context).add(AppStarted())),
        ],
      ),
      body: BlocProvider(
        create: (context) => RegisterBloc(
          repos: repos,
          authBloc: BlocProvider.of<AuthBloc>(context),
        )..add(LoadRegister()),
        child: RegisterEntry(),
      ),
    );
  }
}

class RegisterEntry extends StatefulWidget {
  const RegisterEntry({Key key}) : super(key: key);
  @override
  State<RegisterEntry> createState() => _RegisterEntryState();
}

class _RegisterEntryState extends State<RegisterEntry> {
  final _formKey = GlobalKey<FormState>();
  List<String> currencies = [];

  @override
  Widget build(BuildContext context) {
    final _companyController = TextEditingController()
      ..text = kReleaseMode ? '' : 'My E-Commerce site';
    String _currencySelected = kReleaseMode ? '' : 'Thailand Baht [THB]';
    final _firstNameController = TextEditingController()
      ..text = kReleaseMode ? '' : 'John';
    final _lastNameController = TextEditingController()
      ..text = kReleaseMode ? '' : 'Doe';
    final _emailController = TextEditingController()
      ..text = kReleaseMode ? '' : 'admin@growerp.com';

    return BlocListener<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state is RegisterLoading) {
          _showMessage(context, 'loading the registration form...', Colors.black);
        }
        if (state is RegisterError) {
          _showMessage(context, state.errorMessage, Colors.red);
        }
        if (state is RegisterSubmitting) {
          _showMessage(context, 'Sending the registration...', Colors.black);
        }
        if (state is RegisterSuccess) {
          BlocProvider.of<AuthBloc>(context)
              .add(Login());
        }
        if (state is RegisterLoaded) {
          setState(() {
            currencies = state.currencies;
          });
        }
      },
      child:
          BlocBuilder<RegisterBloc, RegisterState>(builder: (context, state) {
        return Center(
            child: SizedBox(
                width: 400,
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: <Widget>[
                      SizedBox(height: 40),
                      TextFormField(
                        key: Key('companyName'),
                        decoration: InputDecoration(labelText: 'Business name'),
                        controller: _companyController,
                        validator: (value) {
                          if (value.isEmpty)
                            return 'Please enter business name?';
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: 500,
                        height: 60,
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25.0),
                          border: Border.all(
                              color: Colors.grey,
                              style: BorderStyle.solid,
                              width: 0.80),
                        ),
                        child: DropdownButton(
                          underline: SizedBox(), // remove underline
                          hint: Text('Currency'),
                          value: _currencySelected,
                          items: currencies
                              .map((value) => DropdownMenuItem(
                                    child: Text(value),
                                    value: value,
                                  ))
                              .toList(),
                          onChanged: (String newValue) {
                            setState(() {
                              _currencySelected = newValue;
                            });
                          },
                          isExpanded: false,
                        ),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        key: Key('firstName'),
                        decoration: InputDecoration(labelText: 'First Name'),
                        controller: _firstNameController,
                        validator: (value) {
                          if (value.isEmpty)
                            return 'Please enter your first name?';
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        key: Key('lastName'),
                        decoration: InputDecoration(labelText: 'Last Name'),
                        controller: _lastNameController,
                        validator: (value) {
                          if (value.isEmpty)
                            return 'Please enter your last name?';
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      Text('A temporary password will be send by email',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.orange,
                          )),
                      SizedBox(height: 10),
                      TextFormField(
                        key: Key('email'),
                        decoration: InputDecoration(labelText: 'Email address'),
                        controller: _emailController,
                        validator: (String value) {
                          if (value.isEmpty)
                            return 'Please enter Email address?';
                          if (!RegExp(
                                  r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                              .hasMatch(value)) {
                            return 'This is not a valid email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      RaisedButton(
                          child: Text('Register'),
                          onPressed: () {
                            String _currencyAbr = _currencySelected
                                .substring(_currencySelected.indexOf('[') + 1);
                            _currencyAbr = _currencyAbr.substring(
                                0, _currencyAbr.indexOf(']'));
                            if (_formKey.currentState.validate() &&
                                state is! RegisterSubmitting && state is! RegisterLoading)
                              BlocProvider.of<RegisterBloc>(context).add(
                                RegisterButtonPressed(
                                  companyName: _companyController.text,
                                  currency: _currencyAbr,
                                  firstName: _firstNameController.text,
                                  lastName: _lastNameController.text,
                                  email: _emailController.text,
                                ),
                              );
                          }),
                    ],
                  ),
                )));
      }),
    );
  }
}

void _showMessage(context, message, colors) {
  Scaffold.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$message'),
            CircularProgressIndicator(),
          ],
        ),
        backgroundColor: colors,
      ),
    );
}
