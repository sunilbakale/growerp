import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import '../../models/models.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object> get props => [];
}

class AuthLoading extends AuthState {}

class AuthUninitialized extends AuthState {}

class AuthRegister extends AuthState {}

class AuthUpdatePassword extends AuthState {
  final String username, password;
  const AuthUpdatePassword({@required this.username, this.password})
      : assert(username != null, password != null);
  @override
  List<Object> get props => [username];
  @override
  String toString() => 'AuthUpdatePassword: username: $username';
}

class AuthConnectionProblem extends AuthState {
  final String errorMessage;
  const AuthConnectionProblem({@required this.errorMessage})
      : assert(errorMessage != null);
  @override
  List<Object> get props => [errorMessage];
  @override
  String toString() => 'AuthConnectionProblem: errorMessage: $errorMessage';
}

class AuthAuthenticated extends AuthState {
  final Authenticate authenticate;
  const AuthAuthenticated({@required this.authenticate})
      : assert(authenticate != null);
  @override
  List<Object> get props => [authenticate];
  @override
  String toString() => 'Authenticated: username: ${authenticate.user.name}';
}

class AuthUnauthenticated extends AuthState {
  final String passwordChange;
  final Authenticate authenticate;
  const AuthUnauthenticated({this.authenticate, this.passwordChange});
  @override
  List<Object> get props => [authenticate];
  @override
  String toString() => 'Unauthenticated: username: ${authenticate?.user?.name}';
}
