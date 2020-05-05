import 'dart:async';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import '../../services/repos.dart';
import '../../models/models.dart';
import 'auth.dart';

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
        // contains error message or true for connected
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
