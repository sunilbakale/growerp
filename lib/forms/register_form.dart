import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../bloc/@bloc.dart';
import '../services/repos.dart';
import '../helper_functions.dart';
import '../routing_constants.dart';
import '../models/@models.dart';

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
        create: (context) => RegisterBloc(repos: context.repository<Repos>())
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
  Company company;

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
    }, child: Center(
      child: BlocBuilder<CatalogBloc, CatalogState>(builder: (context, state) {
        if (state is CatalogLoaded) company = state.catalog.company;
        return BlocBuilder<RegisterBloc, RegisterState>(
            builder: (context, state) {
          if (state is RegisterLoading || state is RegisterSending)
            return CircularProgressIndicator();
          if (state is RegisterLoaded) {
            currencies = state.currencies;
            return SizedBox(
                width: 400,
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: <Widget>[
                      SizedBox(height: 30),
                      Text(
                        'Register as a customer for ${company.name}',
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
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
                      Visibility(
                          visible: company != null,
                          child: Column(children: [
                            RaisedButton(
                                child: Text(
                                    'Register as a customer for ${company.name}'),
                                onPressed: () {
                                  String _currencyAbr =
                                      _currencySelected.substring(
                                          _currencySelected.indexOf('[') + 1);
                                  _currencyAbr = _currencyAbr.substring(
                                      0, _currencyAbr.indexOf(']'));
                                  if (_formKey.currentState.validate() &&
                                      state is! RegisterSending)
                                    BlocProvider.of<RegisterBloc>(context).add(
                                      RegisterButtonPressed(
                                        companyPartyId: company.partyId,
                                        firstName: _firstNameController.text,
                                        lastName: _lastNameController.text,
                                        email: _emailController.text,
                                      ),
                                    );
                                }),
                            SizedBox(height: 20),
                            Text(
                                "Or also start a new company where you are the admin!",
                                textAlign: TextAlign.center),
                            Text("complete all fields above and below",
                                textAlign: TextAlign.center),
                            SizedBox(height: 10),
                          ])),
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
                      RaisedButton(
                          child: Text('Register AND create new Ecommerce shop'),
                          onPressed: () {
                            String _currencyAbr = _currencySelected
                                .substring(_currencySelected.indexOf('[') + 1);
                            _currencyAbr = _currencyAbr.substring(
                                0, _currencyAbr.indexOf(']'));
                            if (_formKey.currentState.validate() &&
                                state is! RegisterSending)
                              BlocProvider.of<RegisterBloc>(context).add(
                                CreateShopButtonPressed(
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
          }
          return Center(child: Text('Something wrong with state: $state'));
        });
      }),
    ));
  }
}
