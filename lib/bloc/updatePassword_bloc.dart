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
    final regExpRequire = RegExp(r'^(?=.*[0-9])(?=.*[a-zA-Z])(?=.*[!@#$%^&+=]).{8,}');
    return (String confirmPassword) {
      if (confirmPassword == passwordTextFieldBloc.value &&
          regExpRequire.hasMatch(confirmPassword)) {
        return null;
      }
      return '''Both passwords should be the same, \n
        not the same as a previous one, \n
         8 long, an alpha-numeric, a number and a special character''';
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
    print("====updpassword result: $result=====");
    if (result is String) {
      print("===updpassw is a String!");
      emitFailure(failureResponse: result);
    } else emitSuccess(successResponse: 'Password from $username updated');
  }
}
