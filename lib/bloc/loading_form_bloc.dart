import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import '../services/user_repository.dart';
import 'authentication/authentication.dart';
import '../models/models.dart';
import 'dart:async';

class LoadingFormBloc extends FormBloc<String, String> {
  final UserRepository userRepository;
  final AuthenticationBloc authenticationBloc;
  
  final text = TextFieldBloc();

  Authenticate auth;
  StreamSubscription authSubscription;

  LoadingFormBloc({@required this.userRepository,@required this.authenticationBloc})
    : assert(userRepository != null),
      assert(authenticationBloc != null),
      super(isLoading: true) {
     
    authSubscription = authenticationBloc.listen((state) {
        print("==2==is state: $state");
        if (state is AuthenticationAuthenticated) {
          auth = (authenticationBloc.state as AuthenticationAuthenticated).authenticate;
          print("==2== auth: ${auth?.company?.name}");
          text.updateInitialValue("==lastName: ${auth.user.lastName}");
        }
    });
    addFieldBlocs(fieldBlocs: [text]);
  }
  @override
  void onLoading() async {
    print("== loading ====");
    text.updateInitialValue('=========I am prefilled1========');
    print("==2== auth: ${auth?.company?.name}");
    emitLoaded();
  }

  @override
  void onSubmitting() async {
    print(text.value);
    emitSuccess();
  }
}