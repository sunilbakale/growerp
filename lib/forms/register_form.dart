import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../blocs/@bloc.dart';
import '../models/@models.dart';
import '../services/repos.dart';
import '../helper_functions.dart';
import '../routing_constants.dart';

class RegisterForm extends StatelessWidget {
  final bool newCompany;
  final String message;

  const RegisterForm({Key key, this.newCompany, this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Authenticate authenticate;
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      if (state is AuthUnauthenticated) authenticate = state.authenticate;
      return Scaffold(
        key: Key('RegisterForm'),
        appBar: AppBar(
          title: Text(
            authenticate?.company?.partyId == null
                ? 'Register a new company and admin'
                : authenticate.company.partyId == ''
                    ? 'Register as a customer'
                    : authenticate.company.partyId.isNotEmpty
                        ? 'Register as a customer for ${authenticate?.company?.name}'
                        : '',
          ),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.home),
                onPressed: () => Navigator.pushNamed(context, HomeRoute)),
          ],
        ),
        body: BlocProvider(
          create: (BuildContext context) =>
              RegisterBloc(repos: context.repository<Repos>())
                ..add(LoadRegister(
                    companyPartyId: authenticate?.company?.partyId,
                    companyName: authenticate?.company?.name)),
          child: RegisterHeader(message),
        ),
      );
    });
  }
}

class RegisterHeader extends StatefulWidget {
  final String message;
  const RegisterHeader(this.message);

  @override
  State<RegisterHeader> createState() => _RegisterHeaderState(message);
}

class _RegisterHeaderState extends State<RegisterHeader> {
  final String message;
  final _formKey = GlobalKey<FormState>();
  Authenticate authenticate;
  List<String> currencies;
  String companyPartyId;
  String companyName;
  List<Company> companies;

  _RegisterHeaderState(this.message);

  @override
  Widget build(BuildContext context) {
    final _companyController = TextEditingController()
      ..text = kReleaseMode ? '' : 'My Little Ecommerce Shop';
    String _currencySelected = kReleaseMode ? '' : 'Thailand Baht [THB]';
    final _firstNameController = TextEditingController()
      ..text = kReleaseMode ? '' : 'John';
    final _lastNameController = TextEditingController()
      ..text = kReleaseMode ? '' : 'Doe';
    final _emailController = TextEditingController()
      ..text = kReleaseMode ? '' : 'admin@growerp.com';
    Company _companySelected;
    return BlocListener<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state is RegisterError)
          HelperFunctions.showMessage(context, state.errorMessage, Colors.red);
        if (state is RegisterLoading)
          HelperFunctions.showMessage(
              context, 'Loading register form...', Colors.green);
        if (state is RegisterSending)
          HelperFunctions.showMessage(
              context, 'Sending the registration...', Colors.green);
        if (state is RegisterSuccess) {
          BlocProvider.of<AuthBloc>(context).add(LoadAuth());
          Navigator.pop(
              context,
              'Register successfull,' +
                  ' you can now login with your email password');
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
        if (state is AuthUnauthenticated) {
          authenticate = state.authenticate;
          companyPartyId = authenticate?.company?.partyId;
          companyName = authenticate?.company?.name;
        }
        return BlocBuilder<RegisterBloc, RegisterState>(
            builder: (context, state) {
          if (state is RegisterLoading || state is RegisterSending)
            return Center(child: CircularProgressIndicator());
          if (state is RegisterLoaded) {
            currencies = state?.currencies;
            companies = state?.companies;
            _companySelected = companies != null
                ? companies[0]
                : Company(partyId: companyPartyId);
          }
          return Center(
              child: Container(
                  width: 400,
                  child: Form(
                      key: _formKey,
                      child: ListView(children: <Widget>[
                        SizedBox(height: 30),
                        Visibility(
                            // allow selection of company
                            visible:
                                companyPartyId == null || companyPartyId == '',
                            child: Column(children: [
                              Container(
                                width: 400,
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
                          decoration:
                              InputDecoration(labelText: 'Email address'),
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
                        Visibility(
                            // when companyParty is full create customer
                            visible: authenticate?.company?.partyId != null &&
                                authenticate?.company?.partyId != '',
                            child: Column(children: [
                              SizedBox(height: 20),
                              RaisedButton(
                                  key: Key('newCustomer'),
                                  child: Text('Register as a customer'),
                                  onPressed: () {
                                    String _currencyAbr =
                                        _currencySelected.substring(
                                            _currencySelected.indexOf('[') + 1);
                                    _currencyAbr = _currencyAbr.substring(
                                        0, _currencyAbr.indexOf(']'));
                                    if (_formKey.currentState.validate() &&
                                        state is! RegisterSending)
                                      BlocProvider.of<RegisterBloc>(context)
                                          .add(
                                        RegisterButtonPressed(
                                          companyPartyId:
                                              authenticate?.company?.partyId,
                                          firstName: _firstNameController.text,
                                          lastName: _lastNameController.text,
                                          email: _emailController.text,
                                        ),
                                      );
                                  })
                            ])),
                        SizedBox(height: 20),
                        Visibility(
                            visible: authenticate?.company?.partyId ==
                                null, // register new company
                            child: Column(children: [
                              SizedBox(height: 10),
                              TextFormField(
                                key: Key('companyName'),
                                decoration:
                                    InputDecoration(labelText: 'Business name'),
                                controller: _companyController,
                                validator: (value) {
                                  if (value.isEmpty)
                                    return 'Please enter business name?';
                                  return null;
                                },
                              ),
                              SizedBox(height: 20),
                              Container(
                                width: 400,
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
                                  key: Key('dropDown'),
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
                                  isExpanded: true,
                                ),
                              ),
                              SizedBox(height: 20),
                              RaisedButton(
                                  key: Key('newCompany'),
                                  child: Text(
                                      'Register AND create a new Ecommerce shop'),
                                  onPressed: () {
                                    String _currencyAbr =
                                        _currencySelected.substring(
                                            _currencySelected.indexOf('[') + 1);
                                    _currencyAbr = _currencyAbr.substring(
                                        0, _currencyAbr.indexOf(']'));
                                    if (_formKey.currentState.validate() &&
                                        state is! RegisterSending)
                                      BlocProvider.of<RegisterBloc>(context)
                                          .add(
                                        CreateShopButtonPressed(
                                          companyName: _companyController.text,
                                          currency: _currencyAbr,
                                          firstName: _firstNameController.text,
                                          lastName: _lastNameController.text,
                                          email: _emailController.text,
                                        ),
                                      );
                                  }),
                            ]))
                      ]))));
        });
      }),
    );
  }
}
