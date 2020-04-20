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
      if (!connected) {
        yield AuthConnectionProblem();
      } else {
        final Authenticate authenticate = await repos.getAuthenticate();
        if (authenticate?.apiKey != null) {
          yield AuthAuthenticated(authenticate: authenticate);
        } else {
          yield AuthUnauthenticated(authenticate: authenticate);
        }
      }
/*    } else if (event is Subscribe) {
      yield AuthLoading();
      await repos.signUp(
        companyName: event.companyName, partyId: event.partyId,
        firstName: event.firstName, lastName: event.lastName,
        currency: event.currency, email: event.email);
      yield AuthUnauthenticated();
*/
    } else if (event is LoggedIn) {
      yield AuthLoading();
      await repos.persistAuthenticate(event.authenticate);
      yield AuthAuthenticated(authenticate: event.authenticate);
    } else if (event is LoggedOut) {
      yield AuthLoading();
      final Authenticate authenticate = await repos.deleteApiKey();
      yield AuthUnauthenticated(authenticate: authenticate);
    } else if (event is Register) {
      yield AuthLoading();
      yield AuthRegister();
    }
  }
}
