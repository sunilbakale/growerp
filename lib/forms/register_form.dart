import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../bloc/@bloc.dart';
import '../services/repos.dart';
import '../helper_functions.dart';
import '../routing_constants.dart';

class RegisterForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: Key('RegisterForm'),
      appBar: AppBar(
        title: Text('Register'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.home),
              onPressed: () => Navigator.pushNamed(context, HomeRoute)),
        ],
      ),
      body: BlocProvider(
        create: (context) => RegisterBloc(
            repos: context.repository<Repos>(),
            authBloc: BlocProvider.of<AuthBloc>(context))
          ..add(LoadRegister()),
        child: RegisterHeader(),
      ),
    );
  }
}

class RegisterHeader extends StatefulWidget {
  @override
  State<RegisterHeader> createState() => _RegisterHeaderState();
}

class _RegisterHeaderState extends State<RegisterHeader> {
  final _formKey = GlobalKey<FormState>();
  List<String> currencies;

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterBloc, RegisterState>(
        listener: (context, state) {
      if (state is RegisterError) {
        HelperFunctions.showMessage(context, state.errorMessage, Colors.red);
      }
      if (state is RegisterSubmitting) {
        HelperFunctions.showMessage(
            context, 'Sending the registration...', Colors.black);
      }
      if (state is RegisterSuccess) {
        print("====register message sending");
        Navigator.pop(
            context,
            'Register successfull,' +
                ' you can now login with your email password');
      }
      if (state is RegisterLoaded) {
        setState(() {
          currencies = state.currencies;
        });
      }
    }, child: Center(
      child:
          BlocBuilder<RegisterBloc, RegisterState>(builder: (context, state) {
        final _companyController = TextEditingController()
          ..text = kReleaseMode ? '' : 'My E-Commerce site';
        String _currencySelected = kReleaseMode ? '' : 'Thailand Baht [THB]';
        final _firstNameController = TextEditingController()
          ..text = kReleaseMode ? '' : 'John';
        final _lastNameController = TextEditingController()
          ..text = kReleaseMode ? '' : 'Doe';
        final _emailController = TextEditingController()
          ..text = kReleaseMode ? '' : 'admin@growerp.com';

        if (state is RegisterLoading)
          return CircularProgressIndicator();
        else
          return SizedBox(
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
                        if (value.isEmpty) return 'Please enter business name?';
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
                        items: currencies == null
                            ? null
                            : currencies
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
                        if (value.isEmpty) return 'Please enter Email address?';
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
                              state is! RegisterSubmitting &&
                              state is! RegisterLoading)
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
              ));
      }),
    ));
  }
}
