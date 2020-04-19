import 'package:flutter/material.dart';
import 'package:form_bloc/form_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../services/user_repository.dart';
import 'authentication/authentication.dart';
import '../models/authenticate.dart';
import 'dart:async';

class LoginBloc extends FormBloc<String, String> {
  final UserRepository userRepository;
  final AuthenticationBloc authenticationBloc;
  Authenticate authenticate;
  StreamSubscription authSubscription;

  
  final email = TextFieldBloc(
    initialValue: kReleaseMode==false? "info@growerp.com": null,
    validators: [
      FieldBlocValidators.required,
      FieldBlocValidators.email,
    ],
  );

  final password = TextFieldBloc(
    initialValue: kReleaseMode==false?'qqqqqq9!':null,
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
    try {
      authSubscription = await authenticationBloc.listen((state) {
        if (state is AuthenticationUnauthenticated) {
          authenticate = 
            (authenticationBloc.state as AuthenticationUnauthenticated)
              .authenticate;
          email.updateInitialValue(authenticate?.user?.name);
        }
      });
      emitLoaded();
    } catch(e) {
      emitLoadFailed(failureResponse: "catch, error: $e");
    }
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

