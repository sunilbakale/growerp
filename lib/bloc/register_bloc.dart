import 'package:flutter/material.dart';
import 'package:form_bloc/form_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:growerp/models/authenticate.dart';
import 'auth/auth.dart';
import '../services/repos.dart';

class RegisterBloc extends FormBloc<String, String> {
  final Repos repos;
  final AuthBloc authBloc;
  Authenticate authenticate;

  final company = TextFieldBloc(
      initialValue: kReleaseMode == false ? "Test Company" : "",
      validators: [FieldBlocValidators.required]);

  final currency = SelectFieldBloc<String, dynamic>(
      initialValue: kReleaseMode == false ? "Thailand Baht [THB]" : "",
      validators: [FieldBlocValidators.required]);

  final fullName = TextFieldBloc(
      initialValue: kReleaseMode == false ? "GrowERP Admin" : "",
      validators: [FieldBlocValidators.required]);

  final email = TextFieldBloc(
    initialValue: kReleaseMode == false ? "info@growerp.com" : "",
    validators: [
      FieldBlocValidators.required,
      FieldBlocValidators.email,
    ],
  );

  RegisterBloc({
    @required this.repos,
    @required this.authBloc,
  })  : assert(repos != null),
        assert(authBloc != null),
        super(isLoading: true) {
    addFieldBlocs(fieldBlocs: [company, currency, fullName, email]);
  }

  @override
  void onLoading() async {
    dynamic result = await repos.getCurrencies();
    if (result is String) {
      emitLoadFailed(failureResponse: result);
    } else {
      final currencies = result; 
      List<String> temp = [];
      currencies.forEach((r) => temp.add(r.display));
      currency..updateItems(temp);
      emitLoaded();
    }
  }

  @override
  void onSubmitting() async {
    List names = fullName.value.split(" ");
    String lastName = "";
    if (names.length > 1)
      for (int x = 1; x < names.length; x++) lastName += names[x];
    else
      lastName = "enter LastName?";

    String currencyAbr =
        currency.value.substring(currency.value.indexOf('[') + 1);
    currencyAbr = currencyAbr.substring(0, currencyAbr.indexOf(']'));
    dynamic result = await repos.register(
          companyName: company.value,
          currency: currencyAbr,
          firstName: names[0],
          lastName: lastName,
          email: email.value);
    if (result is String) {
      emitFailure(failureResponse: result);
    }
    authenticate = result;
    emitSuccess();
  }
}
