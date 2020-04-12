import 'package:flutter/material.dart';
import 'package:form_bloc/form_bloc.dart';
import '../services/user_repository.dart';
import 'authentication/authentication.dart';
import 'dart:async';
import '../models/models.dart';


class HomeFormBloc extends FormBloc<String, String> {
  final UserRepository userRepository;
  final AuthenticationBloc authenticationBloc;
  Authenticate auth;
  StreamSubscription authSubscription;
  
  HomeFormBloc({
    @required this.userRepository,
    @required this.authenticationBloc,
  })  : assert(userRepository != null),
        assert(authenticationBloc != null)
  { authSubscription = authenticationBloc.listen(
    (state) {
      print("==2==is state: $state");
      if (state is AuthenticationAuthenticated) {
        auth = (authenticationBloc.state as AuthenticationAuthenticated).authenticate;
        print("===1===got auth? ${auth.user.partyId}");
      }
    });
  }

  @override
  void onSubmitting() {
    // TODO: implement onSubmitting
  }

  @override
  void onLoading() async { // for reload
    emitLoaded();
  }
  @override
  Future<void> close() {
    authSubscription.cancel();
    return super.close();
  }
}



