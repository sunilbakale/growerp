import 'dart:async';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../services/repos.dart';
import '../models/models.dart';

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
    } else if (event is Register) {
      yield AuthLoading();
      dynamic result = await repos.register(
          companyName: event.companyName,
          firstName: event.firstName,
          lastName: event.lastName,
          currency: event.currencyId,
          email: event.email);
      if (result is Authenticate)
        yield AuthUnauthenticated();
      else
        yield AuthRegisterProblem(errorMessage: result);
    } else if (event is LoggingIn) {
      yield AuthLoading();
      dynamic result =
          await repos.login(username: event.username, password: event.password);
      if (result is Authenticate)
        yield AuthAuthenticated(authenticate: result);
      else
        yield AuthLoginProblem(errorMessage: result);
    } else if (event is LoggedIn) {
      await repos.persistAuthenticate(event.authenticate);
      yield AuthAuthenticated(authenticate: event.authenticate);
    } else if (event is LoggedOut) {
      yield AuthLoading();
      await repos.logout();
      Authenticate authenticate = event.authenticate;
      if (authenticate == null) {
        authenticate = await repos.getAuthenticate();
      }
      authenticate.apiKey = null;
      await repos.persistAuthenticate(authenticate);
      yield AuthUnauthenticated(authenticate: authenticate);
    } else if (event is Register) {
      yield AuthRegister();
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
      yield AuthUpdatePassword(
          username: event.username, password: event.password);
    } else
      yield AuthUnauthenticated();
  }
}
// --------------------------------events -------------------------------

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

class ConnectionProblem extends AuthEvent {}

class AppStarted extends AuthEvent {}

class Register extends AuthEvent {
  final String companyName;
  final currencyId;
  final firstName;
  final lastName;
  final email;
  const Register(
      {@required this.companyName,
      @required this.currencyId,
      @required this.firstName,
      @required this.lastName,
      @required this.email});
  @override
  List<Object> get props =>
      [companyName, currencyId, firstName, lastName, email];
  @override
  String toString() => 'Register userName: $email company: $companyName';
}
class PrepareRegister extends AuthEvent{}

class ResetPassword extends AuthEvent {
  final String username;
  const ResetPassword({@required this.username});
  @override
  List<Object> get props => [username];
  @override
  String toString() => 'loggedIn userName: $username';
}

class UpdatePassword extends AuthEvent {
  final String username, password;
  const UpdatePassword({@required this.username, this.password});
  @override
  List<Object> get props => [username];
  @override
  String toString() => 'update password userName: $username';
}

class LoggingIn extends AuthEvent {
  final String username;
  final String password;

  const LoggingIn({@required this.username, @required this.password});
  @override
  List<Object> get props => [username, password];
  @override
  String toString() => 'loggingIn userName: $username';
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

// --------------------------------state -------------------------------

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object> get props => [];
}

class AuthLoading extends AuthState {}

class AuthUninitialized extends AuthState {}

class AuthRegister extends AuthState {}
/*  final CurrencyIdList currencyList;
  const AuthRegister({@required this.currencyList});
  @override
  List<Object> get props => [currencyList];
  @override
  String toString() => 'AuthRegister: currencyList length: $currencyList';
}*/

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

class AuthLoginProblem extends AuthState {
  final String errorMessage;
  const AuthLoginProblem({@required this.errorMessage})
      : assert(errorMessage != null);
  @override
  List<Object> get props => [errorMessage];
  @override
  String toString() => 'AuthLoginProblem: errorMessage: $errorMessage';
}

class AuthRegisterProblem extends AuthState {
  final String errorMessage;
  const AuthRegisterProblem({@required this.errorMessage})
      : assert(errorMessage != null);
  @override
  List<Object> get props => [errorMessage];
  @override
  String toString() => 'AuthRegisterProblem: errorMessage: $errorMessage';
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
