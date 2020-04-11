import 'package:flutter/material.dart';
import 'package:form_bloc/form_bloc.dart';
import 'package:dio/dio.dart';
import '../services/user_repository.dart';

class RegisterFormBloc extends FormBloc<String, String> {
  final UserRepository userRepository;

  final company = TextFieldBloc(
    validators: [FieldBlocValidators.required]);

  final currency = SelectFieldBloc<String, dynamic>(
    validators: [FieldBlocValidators.required]);

  final fullName = TextFieldBloc(
    validators: [FieldBlocValidators.required]);

  final email = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
      FieldBlocValidators.email,
    ],
  );
  
  final showSuccessResponse = BooleanFieldBloc();

  RegisterFormBloc({
    @required this.userRepository,
    })  : assert(userRepository != null), super(isLoading: true)
      {    
    addFieldBlocs(
      fieldBlocs: [company, currency, fullName, email, showSuccessResponse]
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

    try {
      await userRepository.signUp(
        companyName: company.value, currency: currency.value,
        firstName: names[0], lastName: lastName, email: email.value);
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
