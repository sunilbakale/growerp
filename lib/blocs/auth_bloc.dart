/*
 * This software is in the public domain under CC0 1.0 Universal plus a
 * Grant of Patent License.
 * 
 * To the extent possible under law, the author(s) have dedicated all
 * copyright and related and neighboring rights to this software to the
 * public domain worldwide. This software is distributed without any
 * warranty.
 * 
 * You should have received a copy of the CC0 Public Domain Dedication
 * along with this software (see the LICENSE.md file). If not, see
 * <http://creativecommons.org/publicdomain/zero/1.0/>.
 */

import 'dart:async';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/@models.dart';

/// Authbloc controls the connection to the backend
///
/// It contains company and user information and signals connection errrors,
/// keeps the token and apiKey in the [Authenticate] class.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final repos;

  AuthBloc({@required this.repos})
      : assert(repos != null),
        super(AuthInitial());

  @override
  Stream<AuthState> mapEventToState(AuthEvent event) async* {
    Authenticate authenticate;
    // ################# local functions ###################

    Future<void> findDefaultCompany() async {
      //print("===15==1==");
      dynamic companies = await repos.getCompanies();
      if (companies is List<Company> && companies.length > 0) {
        // print("===15==2==");
        authenticate = Authenticate(company: companies[0], user: null);
        await repos.persistAuthenticate(authenticate);
      } else {
        //print("===15==3==");
        authenticate = null;
        await repos.persistAuthenticate(authenticate);
      }
    }

    Future<AuthState> checkApikey() async {
      // print("===10==== apiKey: ${authenticate?.apiKey}");
      if (authenticate?.apiKey == null) {
        return AuthUnauthenticated(authenticate);
      } else {
        repos.setApikey(authenticate?.apiKey);
        dynamic result = await repos.checkApikey();
        // print("=====checkapiKey result: $result");
        if (result is bool && result) {
          // print("===11====");
          return AuthAuthenticated(authenticate);
        } else {
          //print("===12====");
          authenticate.apiKey = null; // revoked
          repos.setApikey(null);
          //print("===13====");
          await repos.persistAuthenticate(authenticate);
          return AuthUnauthenticated(authenticate);
        }
      }
    }

    print("==== incoming event: $event");
    // ################# start bloc ###################
    if (event is LoadAuth) {
      yield AuthLoading();
      dynamic connected = await repos.getConnected();
      if (connected is String) {
        yield AuthProblem(connected);
      } else {
        authenticate = await repos.getAuthenticate();
        if (authenticate?.company?.partyId != null) {
          //print("===1====${authenticate.apiKey}");
          // check company
          dynamic result =
              await repos.checkCompany(authenticate.company.partyId);
          if (result == false) await findDefaultCompany();
          // now check user apiKey
          yield await checkApikey();
        } else {
          //print("===3====${authenticate?.apiKey}");
          await findDefaultCompany();
          yield await checkApikey();
        }
      }
    } else if (event is LoggedIn) {
      yield AuthLoading();
      await repos.persistAuthenticate(event.authenticate);
      yield AuthAuthenticated(event.authenticate, "Successfully logged in");
    } else if (event is Logout) {
      yield AuthLoading();
      final Authenticate authenticate = await repos.logout();
      yield AuthUnauthenticated(authenticate, "you are logged out now");
    } else if (event is ResetPassword) {
      await repos.resetPassword(username: event.username);
    } else if (event is UpdateAuth) {
      await repos.persistAuthenticate(event.authenticate);
      yield AuthUnauthenticated(event.authenticate);
    } else if (event is UpdateCompany) {
      yield AuthLoading();
      dynamic result =
          await repos.updateCompany(event.company, event.imagePath);
      if (result is Company) {
        event.authenticate.company = result;
        yield AuthAuthenticated(event.authenticate, 'Company updated');
      } else {
        yield AuthProblem(result, event.company);
      }
    } else if (event is UpdateUser) {
      yield AuthLoading();
      dynamic result = await repos.updateUser(event.user, event.imagePath);
      if (result is User) {
        event.authenticate.user = result;
        yield AuthAuthenticated(event.authenticate, 'User updated');
      } else {
        yield AuthProblem(result, null, event.user);
      }
    }
  }
}

// ################# events ###################
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

class LoadAuth extends AuthEvent {
  @override
  String toString() => 'Load AuthBoc with backend status.';
}

class Logout extends AuthEvent {}

class UpdateAuth extends AuthEvent {
  final Authenticate authenticate;
  UpdateAuth(this.authenticate);
  @override
  List<Object> get props => [authenticate];
  @override
  String toString() => 'Update Authenticate ${authenticate.toString()}';
}

class UpdateCompany extends AuthEvent {
  final Authenticate authenticate;
  final Company company;
  final String imagePath;
  UpdateCompany(this.authenticate, this.company, this.imagePath);
  @override
  List<Object> get props => [authenticate];
  @override
  String toString() => 'Update Company ${authenticate.company.toString()} '
      'new image: ${imagePath != null ? imagePath.length : 0}';
}

class UpdateUser extends AuthEvent {
  final Authenticate authenticate;
  final User user;
  final String imagePath;
  UpdateUser(this.authenticate, this.user, this.imagePath);
  @override
  List<Object> get props => [authenticate];
  @override
  String toString() => 'Update User ${authenticate.user.toString()} ';
}

class DeleteUser extends AuthEvent {
  final Authenticate authenticate;
  final String partyId;
  DeleteUser(this.authenticate, this.partyId);
  @override
  List<Object> get props => [authenticate];
  @override
  String toString() => 'Update User ${authenticate.user.toString()} ';
}

class LoggedIn extends AuthEvent {
  final Authenticate authenticate;
  const LoggedIn({@required this.authenticate});
  @override
  List<Object> get props => [authenticate.user.name];
  @override
  String toString() => 'Logging in userName: ${authenticate.user.toString()}';
}

class ResetPassword extends AuthEvent {
  final String username;
  const ResetPassword({@required this.username});
  @override
  List<Object> get props => [username];
  @override
  String toString() => 'ResetPassword userName: $username';
}

class LoggingOut extends AuthEvent {
  final Authenticate authenticate;
  const LoggingOut({this.authenticate});
  @override
  List<Object> get props => [authenticate];
  @override
  String toString() => 'loggedOut userName: ${authenticate?.user?.name}';
}

class UploadImage extends AuthEvent {
  final String partyId;
  final String fileName;
  UploadImage(this.partyId, this.fileName);
  String toString() => "Upload User $partyId image at $fileName]";
}

// ################## state ###################
abstract class AuthState extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthProblem extends AuthState {
  final String errorMessage;
  final Company newCompany;
  final User newUser;
  AuthProblem(this.errorMessage, [this.newCompany, this.newUser]);
  @override
  List<Object> get props => [errorMessage];
  @override
  String toString() => 'AuthProblem: errorMessage: $errorMessage';
}

class AuthAuthenticated extends AuthState {
  final String message;
  final Authenticate authenticate;
  AuthAuthenticated(this.authenticate, [this.message]);
  @override
  List<Object> get props => [authenticate];
  @override
  String toString() =>
      'Authenticated: Msg: $message ${authenticate.toString()}';
}

class AuthUnauthenticated extends AuthState {
  final String message;
  final Authenticate authenticate;
  AuthUnauthenticated(this.authenticate, [this.message]);
  @override
  List<Object> get props => [authenticate];
  @override
  String toString() =>
      'Unauthenticated: msg: $message ${authenticate.toString()}';
}
