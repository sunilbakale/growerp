import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import '../../models/models.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();
  @override
  List<Object> get props => [];
}

class ConnectionProblem extends AuthenticationEvent {}
class AppStarted extends AuthenticationEvent {}

class LoggedIn extends AuthenticationEvent {
  final Authenticate authenticate;
  const LoggedIn({@required this.authenticate});
  @override
  List<Object> get props => [authenticate];
  @override
  String toString() => 'loggedIn userName: ${authenticate.user.name}';
}

class LoggedOut extends AuthenticationEvent {
  final Authenticate authenticate;
  const LoggedOut({this.authenticate});
  @override
  List<Object> get props => [authenticate];
  @override
  String toString() => 'loggedOut userName: ${authenticate?.user?.name}';
}

