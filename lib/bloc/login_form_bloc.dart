import 'package:flutter/material.dart';
import 'package:form_bloc/form_bloc.dart';
import '../services/user_repository.dart';
import 'authentication/authentication.dart';
import 'package:dio/dio.dart';

class LoginFormBloc extends FormBloc<String, String> {
  final UserRepository userRepository;
  final AuthenticationBloc authenticationBloc;
  
  final email = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
      FieldBlocValidators.email,
    ],
  );

  final password = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
    ],
  );

  final showSuccessResponse = BooleanFieldBloc();

  LoginFormBloc({
    @required this.userRepository,
    @required this.authenticationBloc,
    })  : assert(userRepository != null),
        assert(authenticationBloc != null)
      {    
      addFieldBlocs(
      fieldBlocs: [
        email,
        password,
      ],
    );
  }

  @override
  void onSubmitting() async {
    print(email.value);
    print(password.value);
    print(showSuccessResponse.value);

    try {
      final authenticate = await userRepository.authenticate(
        username: email.value,
        password: password.value,
      );
      emitSuccess();
      authenticationBloc.add(LoggedIn(token: authenticate));
    } on DioError catch(e) {
      if(e.response.statusCode == 404){
         print(e.response.statusCode);
      } else {
        print(e.message);
        print(e.request);
      }
      emitFailure(failureResponse: 'yes error');
    }
  }
}

