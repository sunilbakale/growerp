import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import '../services/repos.dart';
import '../models/@models.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final Repos repos;

  LoginBloc({
    @required this.repos,
  })  : assert(repos != null),
        super(LoginInitial());

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoadLogin) {
      yield LoginLoading();
      dynamic companies = await repos.getCompanies();
      if (companies is Companies) yield LoginLoaded(companies.companies);
      if (companies is String) yield LoginError(errorMessage: companies);
    } else if (event is LoginButtonPressed) {
      yield LogginInProgress();
      final result = await repos.login(
        companyPartyId: event.companyPartyId,
        username: event.username,
        password: event.password,
      );
      if (result is Authenticate) {
        yield LoginOk(authenticate: result);
      } else if (result == "passwordChange") {
        yield LoginChangePw(username: event.username, password: event.password);
      } else {
        yield LoginError(errorMessage: result);
      }
    }
  }
}

//--------------------------events ---------------------------------
abstract class LoginEvent extends Equatable {
  const LoginEvent();
  @override
  List<Object> get props => [];
}

class LoadLogin extends LoginEvent {}

class LoginButtonPressed extends LoginEvent {
  final String companyPartyId;
  final String username;
  final String password;

  const LoginButtonPressed({
    @required this.companyPartyId,
    @required this.username,
    @required this.password,
  });

  @override
  String toString() => 'LoginButtonPressed { username: $username }';
}

// -------------------------------state ------------------------------
abstract class LoginState extends Equatable {
  const LoginState();
  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginLoaded extends LoginState {
  final List companies;
  LoginLoaded(this.companies);
  @override
  List<Object> get props => [companies];
  String toString() =>
      'Login loaded, size ${companies.length} first one: ${companies[0].name}';
}

class LoginChangePw extends LoginState {
  final String username;
  final String password;
  const LoginChangePw({@required this.username, @required this.password});
  @override
  List<Object> get props => [username];
  @override
  String toString() => 'LoginChangePw { username: $username }';
}

class LoginOk extends LoginState {
  final Authenticate authenticate;
  const LoginOk({@required this.authenticate});
  @override
  List<Object> get props => [authenticate];
  @override
  String toString() => 'LoginOk { username: ${authenticate.user.name} }';
}

class LogginInProgress extends LoginState {}

class LoginError extends LoginState {
  final String errorMessage;
  const LoginError({@required this.errorMessage});
  @override
  List<Object> get props => [errorMessage];
  @override
  String toString() => 'LoginError { error: $errorMessage }';
}
