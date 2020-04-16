import 'package:flutter/material.dart';
import 'package:form_bloc/form_bloc.dart';
import '../services/user_repository.dart';
import 'authentication/authentication.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoginBloc extends FormBloc<String, String> {
  final UserRepository userRepository;
  final AuthenticationBloc authenticationBloc;
  
  final email = TextFieldBloc(
    initialValue: kReleaseMode==false? "info@growerp.com": null,
    validators: [
      FieldBlocValidators.required,
      FieldBlocValidators.email,
    ],
  );

  final password = TextFieldBloc(
    initialValue: kReleaseMode==false?'qqqqqq9!':'',
    validators: [
      FieldBlocValidators.required,
    ],
  );

  LoginBloc({
    @required this.userRepository,
    @required this.authenticationBloc,
    })  : assert(userRepository != null),
        assert(authenticationBloc != null), super(isLoading: true)
      {    
      addFieldBlocs(
      fieldBlocs: [email, password]);
  }

  @override
  void onLoading() async {
    emitLoaded();
  }

  @override
  void onSubmitting() async {
    print(email.value);
    print(password.value);

    try {
      final authenticate = await userRepository.authenticate(
        username: email.value,
        password: password.value,
      );
      authenticationBloc.add(LoggedIn(authenticate: authenticate));
      emitSuccess();
    } on DioError catch(e) {
/*      if(e.response != null) {
          print("login error data: ${e.response.data}");
          print("login error header: ${e.response.headers}");
          print("login error request: ${e.response.request}");
      } else{
          // Something happened in setting up or sending the request that triggered an Error
          print("login no response, request: ${e.request}");
          print("login no response, message: ${e.message}");
      }
*/      emitFailure(failureResponse: e.response.data['errors']);
    }
  }
}

