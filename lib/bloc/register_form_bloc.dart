import 'package:flutter/material.dart';
import 'package:form_bloc/form_bloc.dart';
import 'package:dio/dio.dart';
import '../services/user_repository.dart';

class RegisterFormBloc extends FormBloc<String, String> {
  final UserRepository userRepository;

  final company = TextFieldBloc(
    validators: [
        FieldBlocValidators.required,
    ],
  );
  final currency = SelectFieldBloc(
    validators: [
        FieldBlocValidators.required,
    ],
    items: ['EUR', 'USD', 'THB'],
  );
  final fullName = TextFieldBloc(
    validators: [
        FieldBlocValidators.required,
    ],
  );
  final email = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
      FieldBlocValidators.email,
    ],
  );
  
  final showSuccessResponse = BooleanFieldBloc();

  RegisterFormBloc({
    @required this.userRepository,
    })  : assert(userRepository != null)       
      {    
    addFieldBlocs(
      fieldBlocs: [
        company,
        currency,
        fullName,
        email,
        showSuccessResponse,
      ],
    );
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
      if(e.response != null) {
          print(e.response.data);
          print(e.response.headers);
          print(e.response.request);
      } else{
          // Something happened in setting up or sending the request that triggered an Error
          print(e.request);
          print(e.message);
      }
      emitFailure(failureResponse: 'Registration error');
    }
  }
}
