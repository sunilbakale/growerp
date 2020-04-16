import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:growerp/models/authenticate.dart';
import '../services/user_repository.dart';
import 'authentication/authentication.dart';
import 'dart:async';


class HomeFormBloc extends FormBloc<String, String> {
  final UserRepository userRepository;
  final AuthenticationBloc authenticationBloc;
  Authenticate authenticate;
  final company = TextFieldBloc();
  StreamSubscription authSubscription;

  HomeFormBloc({@required this.userRepository,
              @required this.authenticationBloc})
  : assert(userRepository != null),
    assert(authenticationBloc != null),
    super(isLoading: true) {
      addFieldBlocs(fieldBlocs: [company]);
  }

  @override
  void onSubmitting() {
    // TODO: implement onSubmitting
  }

  @override
  void onLoading() async { // for reload
  try {
    authSubscription = await authenticationBloc.listen((state) {
      if (state is AuthenticationAuthenticated) {
        authenticate = 
          (authenticationBloc.state as AuthenticationAuthenticated)
          .authenticate;
      }
    });
    company.updateInitialValue(authenticate.company.name);
    emitLoaded();
    } catch(e) {
      emitLoadFailed(failureResponse: "catch, error: $e");
    }
  }
  @override
  Future<void> close() {
    authSubscription.cancel();
    return super.close();
  }
}


