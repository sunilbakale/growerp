import 'package:flutter/material.dart';
import 'package:form_bloc/form_bloc.dart';
import 'package:flutter/foundation.dart';
import '../services/repos.dart';
import 'auth/auth.dart';

class UpdatePasswordBloc extends FormBloc<String, String> {
  final Repos repos;
  final AuthBloc authBloc;
  final String username, password;

  final newPassword = 
      TextFieldBloc(validators: [FieldBlocValidators.required]);

  final confirmPassword =
      TextFieldBloc(validators: [FieldBlocValidators.required]);

  Validator<String> _confirmPassword(
    TextFieldBloc passwordTextFieldBloc,
  ) {
    return (String confirmPassword) {
      if (confirmPassword == passwordTextFieldBloc.value) {
        return null;
      }
      return 'Must be equal to New Password';
    };
  }

  UpdatePasswordBloc(
      {@required this.repos,
      @required this.authBloc,
      @required this.username,
      @required this.password})
      : assert(repos != null),
        assert(authBloc != null),
        assert(username != null),
        assert(password != null) {
    addFieldBlocs(fieldBlocs: [newPassword, confirmPassword]);
    confirmPassword
      ..addValidators([_confirmPassword(newPassword)])
      ..subscribeToFieldBlocs([newPassword]);
  }

  @override
  void onSubmitting() async {
    dynamic result = await repos.updatePassword(
        username: username,
        oldPassword: password,
        newPassword: newPassword.value);
    if (result is String) {
      emitFailure(failureResponse: result);
    }
    emitSuccess();
  }
}
