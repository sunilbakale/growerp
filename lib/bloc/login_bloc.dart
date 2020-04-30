import 'package:flutter/material.dart';
import 'package:form_bloc/form_bloc.dart';
import 'package:flutter/foundation.dart';
import '../services/repos.dart';
import 'auth/auth.dart';
import '../models/authenticate.dart';
import 'dart:async';

class LoginBloc extends FormBloc<String, String> {
  final Repos repos;
  final AuthBloc authBloc;
  Authenticate authenticate;
  StreamSubscription authSubscription;

  final email = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
      FieldBlocValidators.email,
    ],
  );

  final password = TextFieldBloc(
    initialValue: kReleaseMode == false ? 'qqqqqq9!' : null,
    validators: [
      FieldBlocValidators.required,
    ],
  );

  LoginBloc({@required this.repos, @required this.authBloc})
      : assert(repos != null),
        assert(authBloc != null),
        super(isLoading: true) {
    addFieldBlocs(fieldBlocs: [email, password]);
  }

  @override
  void onLoading() async {
    authBloc.add(AppStarted());
    try {
      authSubscription = await authBloc.listen((state) {
        if (state is AuthConnectionProblem) {
          String errorMessage = (authBloc.state as AuthConnectionProblem).errorMessage;
          emitLoadFailed(failureResponse: errorMessage);
        }
        if (state is AuthUnauthenticated) {
          authenticate = (authBloc.state as AuthUnauthenticated).authenticate;
          email.updateInitialValue(authenticate?.user?.name);
          emitLoaded();
        }
      });
    } catch (e) {
      emitLoadFailed(failureResponse: "catch, error: $e");
    }
  }

  @override
  void onSubmitting() async {
    dynamic result =
        await repos.login(username: email.value, password: password.value);
    if (result is String) {
      if (result == "passwordChange") {
        emitSuccess(successResponse: result);
      } else {
        emitFailure(failureResponse: result);
      }
    } else {
      authenticate = result;
      emitSuccess();
    }
  }

  @override
  Future<void> close() {
    authSubscription.cancel();
    return super.close();
  }
}
