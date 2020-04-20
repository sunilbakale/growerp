import 'dart:async';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import '../../services/user_repository.dart';
import '../../models/models.dart';
import 'auth.dart';

class AuthBloc
    extends Bloc<AuthEvent, AuthState> {
  final UserRepository userRepository;

  AuthBloc({@required this.userRepository})
      : assert(userRepository != null);

  @override
  AuthState get initialState => AuthUninitialized();

  @override
  // actual userRepository.authentiate done by login bloc
  Stream<AuthState> mapEventToState(
    AuthEvent event) async* {
    if (event is AppStarted) {
      final connected = await userRepository.connected();
      if (!connected) {
        yield AuthConnectionProblem();
      } else {
        final Authenticate authenticate = await userRepository.getAuthenticate();
        if (authenticate?.apiKey != null) {
          print("=====apiKey found!");
          yield AuthAuthenticated(authenticate: authenticate);
        } else {
          print("==NO===apiKey found!");
          yield AuthUnauthenticated(authenticate: authenticate);
        }
      }
/*    } else if (event is Subscribe) {
      yield AuthLoading();
      await userRepository.signUp(
        companyName: event.companyName, partyId: event.partyId,
        firstName: event.firstName, lastName: event.lastName,
        currency: event.currency, email: event.email);
      yield AuthUnauthenticated();
*/    } else if (event is LoggedIn) {
      yield AuthLoading();
      await userRepository.persistAuthenticate(event.authenticate);
      yield AuthAuthenticated(authenticate: event.authenticate);
    } else if (event is LoggedOut) {
      yield AuthLoading();
      final Authenticate authenticate = await userRepository.deleteApiKey();
      yield AuthUnauthenticated(authenticate: authenticate);
    } else if (event is Register) {
      yield AuthLoading();
      yield AuthRegister();
    }
  }
}
