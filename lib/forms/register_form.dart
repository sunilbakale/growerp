import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../blocs/@bloc.dart';
import '../services/repos.dart';
import '../helper_functions.dart';
import '../routing_constants.dart';
import 'login_form.dart';

class RegisterForm extends StatelessWidget {
  final LoginArgs loginArgs; // if present just register as customer
  const RegisterForm({Key key, this.loginArgs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: Key('RegisterForm'),
      appBar: AppBar(
        title: Text(
          loginArgs?.companyPartyId == null
              ? 'Register a new company and admin'
              : loginArgs?.companyPartyId == ''
                  ? 'Register as a customer'
                  : loginArgs?.companyPartyId != null
                      ? 'Register as a customer for ${loginArgs?.companyName}'
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
                  companyPartyId: loginArgs.companyPartyId,
                  companyName: loginArgs.companyName)),
        child: RegisterHeader(loginArgs),
      ),
    );
  }
}

class RegisterHeader extends StatefulWidget {
  final LoginArgs loginArgs;

  const RegisterHeader(this.loginArgs);
  @override
  State<RegisterHeader> createState() => _RegisterHeaderState(loginArgs);
}

class _RegisterHeaderState extends State<RegisterHeader> {
  final LoginArgs loginArgs; // contains message and current company info
  final _formKey = GlobalKey<FormState>();
  List<String> currencies;

  _RegisterHeaderState(this.loginArgs);

  @override
  Widget build(BuildContext context) {
    print(
        "========2========comp party: ${loginArgs?.companyName}[${loginArgs?.companyPartyId}]");
    final _companyController = TextEditingController()
      ..text = kReleaseMode ? '' : 'My Little Ecommerce Shop';
    String _currencySelected = kReleaseMode ? '' : 'Thailand Baht [THB]';
    final _firstNameController = TextEditingController()
      ..text = kReleaseMode ? '' : 'John';
    final _lastNameController = TextEditingController()
      ..text = kReleaseMode ? '' : 'Doe';
    final _emailController = TextEditingController()
      ..text = kReleaseMode ? '' : 'admin@growerp.com';
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
        if (state is RegisterSuccess)
          Navigator.pop(
              context,
              'Register successfull,' +
                  ' you can now login with your email password');
      },
      child:
          BlocBuilder<RegisterBloc, RegisterState>(builder: (context, state) {
        print("current register state: ${state.runtimeType}");
        if (state is RegisterLoading || state is RegisterSending)
          return Center(child: CircularProgressIndicator());
        if (state is RegisterLoaded) {
          print(
              "========3========comp party: ${loginArgs?.companyName}[${loginArgs?.companyPartyId}]");
          currencies = state.currencies;
          return Center(
              child: Container(
                  width: 400,
                  child: Form(
                      key: _formKey,
                      child: ListView(children: <Widget>[
                        SizedBox(height: 30),
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
                            // allow company selection
                            visible: loginArgs?.companyPartyId != null &&
                                loginArgs.companyPartyId != '',
                            child: Column(children: [
                              SizedBox(height: 20),
                              RaisedButton(
                                  key: Key('newCustomer'),
                                  child: Text(
                                      'Register as a customer for ${loginArgs?.companyName}'),
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
                                              loginArgs?.companyPartyId,
                                          firstName: _firstNameController.text,
                                          lastName: _lastNameController.text,
                                          email: _emailController.text,
                                        ),
                                      );
                                  })
                            ])),
                        SizedBox(height: 20),
                        Visibility(
                            visible: loginArgs?.companyPartyId ==
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
                                      'Register AND create new Ecommerce shop'),
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
        }
        return Center(child: Text('Something wrong with state: $state'));
      }),
    );
  }
}
