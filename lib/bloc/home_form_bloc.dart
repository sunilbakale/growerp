import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import '../services/user_repository.dart';
import 'authentication/authentication.dart';
import 'dart:async';


class HomeFormBloc extends FormBloc<String, String> {
  final UserRepository userRepository;
  final AuthenticationBloc authenticationBloc;
  final company = TextFieldBloc();
  var companyName;
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
    print("==start loading ====");
    authSubscription = await authenticationBloc.listen((state) {
      print("==2==is state: $state");
      if (state is AuthenticationAuthenticated) {
        companyName = (authenticationBloc.state as AuthenticationAuthenticated)
          .authenticate.company.name;
        print("==company1==$companyName"); //ok
      }
    });
    print("==company2==$companyName");
    if (companyName != null) {
      company.updateInitialValue(companyName);
      print("==end company.value: ${company.value.toString()}");
    }
    emitLoaded();
    print("==end loading ====");
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



