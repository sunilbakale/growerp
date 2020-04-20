import 'package:flutter/material.dart';
import 'package:form_bloc/form_bloc.dart';
import 'package:flutter/foundation.dart';
import '../services/repos.dart';
import 'auth/auth.dart';
import '../models/authenticate.dart';
import 'dart:async';

class HomeBloc extends FormBloc<String, String> {
  final Repos repos;
  final AuthBloc authBloc;
  Authenticate authenticate;
  final company = TextFieldBloc();
  StreamSubscription authSubscription;

  HomeBloc({@required this.repos, @required this.authBloc})
      : assert(repos != null),
        assert(authBloc != null),
        super(isLoading: true) {
    addFieldBlocs(fieldBlocs: [company]);
  }

  @override
  void onLoading() async {
    try {
      authSubscription = await authBloc.listen((state) {
        print("====home bloc state: $state");
        if (state is AuthAuthenticated) {
          authenticate =
              (authBloc.state as AuthAuthenticated)
                  .authenticate;
        }
      });
      print("=====home bloc company: ${authenticate?.company?.name}");
      emitLoaded();
    } catch (e) {
      emitLoadFailed(failureResponse: "catch, error: $e");
    }
  }

  @override
  void onSubmitting() {
    // TODO: implement onSubmitting
  }

  @override
  Future<void> close() {
    authSubscription.cancel();
    return super.close();
  }
}
