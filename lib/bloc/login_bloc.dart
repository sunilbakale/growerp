import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'auth_bloc.dart';
import 'package:meta/meta.dart';
import '../services/repos.dart';
import '../models/models.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final Repos repos;
  final AuthBloc authBloc;

  LoginBloc({
    @required this.repos,
    @required this.authBloc,
  })  : assert(repos != null),
        assert(authBloc != null);

  @override
  LoginState get initialState => LoginInitial();

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoginButtonPressed) {
      yield LoginInProgress();

        final authenticate = await repos.login(
          username: event.username,
          password: event.password,
        );
        if (authenticate is Authenticate) {
          authBloc.add(LoggedIn(authenticate: authenticate));
          yield LoginInitial();
        } else {
          yield LoginFailure(error: authenticate);
      }
    }
  }
}

//--------------------------events ---------------------------------
abstract class LoginEvent extends Equatable {
  const LoginEvent();
}

class LoginButtonPressed extends LoginEvent {
  final String username;
  final String password;

  const LoginButtonPressed({
    @required this.username,
    @required this.password,
  });

  @override
  List<Object> get props => [username, password];

  @override
  String toString() =>
      'LoginButtonPressed { username: $username, password: $password }';
}

// -------------------------------state ------------------------------
abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}

class LoginInProgress extends LoginState {}

class LoginFailure extends LoginState {
  final String error;

  const LoginFailure({@required this.error});

  @override
  List<Object> get props => [error];

  @override
  String toString() => 'LoginFailure { error: $error }';
}
