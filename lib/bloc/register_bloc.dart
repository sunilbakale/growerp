import 'package:flutter/material.dart';
import 'package:form_bloc/form_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'authentication/authentication.dart';
import '../services/user_repository.dart';


class RegisterBloc extends FormBloc<String, String> {
  final UserRepository userRepository;
  final AuthenticationBloc authenticationBloc;

  final company = TextFieldBloc(
    initialValue: kReleaseMode==false?"Test Company":"",
    validators: [FieldBlocValidators.required]);

  final currency = SelectFieldBloc<String, dynamic>(
    initialValue: kReleaseMode==false?"Thailand Baht [THB]":"",
    validators: [FieldBlocValidators.required]);

  final fullName = TextFieldBloc(
    initialValue: kReleaseMode==false?"GrowERP Admin":"",
    validators: [FieldBlocValidators.required]);

  final email = TextFieldBloc(
    initialValue: kReleaseMode==false?"info@growerp.com":"",
    validators: [
      FieldBlocValidators.required,
      FieldBlocValidators.email,
    ],
  );
  
  RegisterBloc({
    @required this.userRepository,
    @required this.authenticationBloc,
    })  : assert(userRepository != null),
        assert(authenticationBloc != null), super(isLoading: true)
  {    
    addFieldBlocs(
      fieldBlocs: [company, currency, fullName, email]
    );
  }

  @override
  void onLoading() async {
    try {
      final currencies = await userRepository.getCurrencies();
      List<String> temp = [];
      currencies.forEach((r) => temp.add(r.display));
      currency..updateItems(temp);
      emitLoaded();
    } catch(e) {
      print("currency loading problem: $e ");
      emitLoadFailed();
    }
  }

  @override
  void onSubmitting() async {
    print(company.value);
    print(currency.value);
    print(fullName.value);
    print(email.value);

    List names = fullName.value.split(" ");
    String lastName = "";
    if (names.length > 1) 
      for (int x = 1; x < names.length; x++)
        lastName += names[x];
    else lastName = "enter LastName?";

    String currencyAbr = currency.value.substring(currency.value.indexOf('[')+1);
    currencyAbr = currencyAbr.substring(0, currencyAbr.indexOf(']'));
    try {
      await userRepository.signUp(
        companyName: company.value, currency: currencyAbr,
        firstName: names[0], lastName: lastName, email: email.value);
//      authenticationBloc.add(AppStarted());
      emitSuccess();
    } on DioError catch(e) {
/*      if(e.response != null) {
          print("register error data: ${e.response.data}");
          print("register error header: ${e.response.headers}");
          print("register error request: ${e.response.request}");
      } else{
          // Something happened in setting up or sending the request that triggered an Error
          print("register no response, request: ${e.request}");
          print("register no response, message: ${e.message}");
      }
*/    emitFailure(failureResponse: e.response.data['errors']);
    }
  }
}
