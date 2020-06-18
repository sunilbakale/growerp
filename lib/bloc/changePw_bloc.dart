import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'auth_bloc.dart';
import 'package:meta/meta.dart';
import '../services/repos.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ChangePwBloc extends Bloc<ChangePwEvent, ChangePwState> {
  final Repos repos;
  final AuthBloc authBloc;

  ChangePwBloc({
    @required this.repos,
    @required this.authBloc,
  })  : assert(repos != null),
        assert(authBloc != null);

  @override
  ChangePwState get initialState => ChangePwInitial();

  @override
  Stream<ChangePwState> mapEventToState(ChangePwEvent event) async* {
    if (event is ChangePwButtonPressed) {
      yield ChangePwInProgress();
      final result = await repos.updatePassword(
          username: event.username,
          oldPassword: event.oldPassword,
          newPassword: event.newPassword);
      if (result is String)
        yield ChangePwFailure(message: result);
      else
        authBloc.add(Login());
      Fluttertoast.showToast(
          toastLength: Toast.LENGTH_LONG, msg: "Password updated!");
    }
  }
}

//--------------------------events ---------------------------------
abstract class ChangePwEvent extends Equatable {
  const ChangePwEvent();
  @override
  List<Object> get props => [];
}

class ChangePwButtonPressed extends ChangePwEvent {
  final String username;
  final String oldPassword;
  final String newPassword;

  const ChangePwButtonPressed({
    @required this.username,
    @required this.oldPassword,
    @required this.newPassword,
  });

  @override
  String toString() => 'ChangePwButtonPressed { username: $username }';
}

// -------------------------------state ------------------------------
abstract class ChangePwState extends Equatable {
  const ChangePwState();

  @override
  List<Object> get props => [];
}

class ChangePwInitial extends ChangePwState {}

class ChangePwInProgress extends ChangePwState {}

class ChangePwFailure extends ChangePwState {
  final String message;

  const ChangePwFailure({@required this.message});

  @override
  List<Object> get props => [message];

  @override
  String toString() => 'ChangePwFailed { error: $message }';
}
