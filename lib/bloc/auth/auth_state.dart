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

class AuthConnectionProblem extends AuthState {}

class AuthRegister extends AuthState {}

class AuthAuthenticated extends AuthState {
  final Authenticate authenticate;
  const AuthAuthenticated({@required this.authenticate})
      : assert(authenticate != null);
  @override
  List<Object> get props => [authenticate];
  @override
  String toString() => 'Authenticated: userName: ${authenticate.user.name}';
}

class AuthUnauthenticated extends AuthState {
  final Authenticate authenticate;
  const AuthUnauthenticated({this.authenticate});
  @override
  List<Object> get props => [authenticate];
  @override
  String toString() => 'Unauthenticated: userName: ${authenticate?.user?.name}';
}
