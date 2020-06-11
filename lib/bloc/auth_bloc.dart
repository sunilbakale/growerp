import 'dart:async';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../services/repos.dart';
import '../models/@models.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Repos repos;

  AuthBloc({@required this.repos}) : assert(repos != null);

  @override
  AuthState get initialState => AuthUninitialized();

  @override
  // actual repos.authentiate done by login bloc
  Stream<AuthState> mapEventToState(AuthEvent event) async* {
    if (event is AppStarted) {
      final connected = await repos.connected();
      if (connected is String) {
        // contains string error message or true for connected
        yield AuthConnectionProblem(errorMessage: connected);
      } else {
        final Authenticate authenticate = await repos.getAuthenticate();
        if (authenticate?.apiKey != null) {
          yield AuthAuthenticated(authenticate: authenticate);
        } else {
          yield AuthUnauthenticated(authenticate: authenticate);
        }
      }
    } else if (event is LoggedIn) {
      await repos.persistAuthenticate(event.authenticate);
      yield AuthAuthenticated(authenticate: event.authenticate);
    } else if (event is Register) {
      yield AuthRegister();
    } else if (event is Login) {
      final Authenticate authenticate = await repos.getAuthenticate();
      yield AuthLogin(authenticate: authenticate);
    } else if (event is Logout) {
      final Authenticate authenticate = await repos.logout();
      yield AuthUnauthenticated(authenticate: authenticate);
    } else if (event is ResetPassword) {
      yield AuthLoading();
      dynamic result = await repos.resetPassword(username: event.username);
      if (result is String)
        yield AuthConnectionProblem(errorMessage: result);
      else {
        Authenticate authenticate = await repos.getAuthenticate();
        yield AuthUnauthenticated(authenticate: authenticate);
      }
    } else if (event is UpdatePassword) {
      yield AuthLoading();
      yield AuthUpdatePassword(
          username: event.username, password: event.password);
    } else
      yield AuthUnauthenticated();
  }
}

//--------------------------events---------------------------------------
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

class ConnectionProblem extends AuthEvent {}
class AppStarted extends AuthEvent {}
class Register extends AuthEvent {}
class Login extends AuthEvent {}
class Logout extends AuthEvent {}

class LoggedIn extends AuthEvent {
  final Authenticate authenticate;
  const LoggedIn({@required this.authenticate});
  @override
  List<Object> get props => [authenticate.user.name];
  @override
  String toString() => 'LoggingIn userName: ${authenticate.user.name}';
}

class ResetPassword extends AuthEvent {
  final String username;
  const ResetPassword({@required this.username});
  @override
  List<Object> get props => [username];
  @override
  String toString() => 'LoggingIn userName: $username';
}

class UpdatePassword extends AuthEvent {
  final String username, password;
  const UpdatePassword({@required this.username, this.password});
  @override
  List<Object> get props => [username];
  @override
  String toString() => 'update password userName: $username';
}

class LoggingOut extends AuthEvent {
  final Authenticate authenticate;
  const LoggingOut({this.authenticate});
  @override
  List<Object> get props => [authenticate];
  @override
  String toString() => 'loggedOut userName: ${authenticate?.user?.name}';
}

//------------------------------state ------------------------------------
abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object> get props => [];
}

class AuthLoading extends AuthState {}
class AuthUninitialized extends AuthState {}
class AuthLogin extends AuthState {
  final Authenticate authenticate;
  const AuthLogin({this.authenticate});
  @override
  List<Object> get props => [authenticate?.user?.name];
  @override
  String toString() => 'AuthLogin: username: ${authenticate?.user?.name}';
}
class AuthHome extends AuthState {
  final Authenticate authenticate;
  const AuthHome({this.authenticate});
}
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
  String toString() => 'AuthAuthenticated: username: ${authenticate.user.name}';
}

class AuthUnauthenticated extends AuthState {
  final String passwordChange;
  final Authenticate authenticate;
  const AuthUnauthenticated({this.authenticate, this.passwordChange});
  @override
  List<Object> get props => [authenticate];
  @override
  String toString() => 'AuthUnauthenticated: username: ${authenticate?.user?.name}';
}
