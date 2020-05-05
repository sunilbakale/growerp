import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import '../../models/models.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

class ConnectionProblem extends AuthEvent {}

class AppStarted extends AuthEvent {}

class Register extends AuthEvent {}

class ResetPassword extends AuthEvent {
  final String username;
  const ResetPassword({@required this.username});
  @override
  List<Object> get props => [username];
  @override
  String toString() => 'loggedIn userName: ${username}';
}

class UpdatePassword extends AuthEvent {
  final String username, password;
  const UpdatePassword({@required this.username, this.password});
  @override
  List<Object> get props => [username];
  @override
  String toString() => 'update password userName: ${username}';
}

class LoggedIn extends AuthEvent {
  final Authenticate authenticate;
  const LoggedIn({@required this.authenticate});
  @override
  List<Object> get props => [authenticate];
  @override
  String toString() => 'loggedIn userName: ${authenticate.user.name}';
}

class LoggedOut extends AuthEvent {
  final Authenticate authenticate;
  const LoggedOut({this.authenticate});
  @override
  List<Object> get props => [authenticate];
  @override
  String toString() => 'loggedOut userName: ${authenticate?.user?.name}';
}
