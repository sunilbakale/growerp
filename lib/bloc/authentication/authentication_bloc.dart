import 'dart:async';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import '../../services/user_repository.dart';
import '../../models/models.dart';
import 'authentication.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository userRepository;

  AuthenticationBloc({@required this.userRepository})
      : assert(userRepository != null);

  @override
  AuthenticationState get initialState => AuthenticationUninitialized();

  @override
  // actual userRepository.authentiate done by login bloc
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event) async* {
    if (event is AppStarted) {
      final connected = await userRepository.getSessionToken();
      if (connected != true) {
        yield AuthenticationConnectionProblem();
      } else {
        final Authenticate authenticate = await userRepository.hasAuthenticate();
        if (authenticate != null) {
          yield AuthenticationAuthenticated(authenticate: authenticate);
        } else {
          yield AuthenticationUnauthenticated();
        }
      }
    } else if (event is LoggedIn) {
      yield AuthenticationLoading();
      await userRepository.persistToken(event.authenticate);
      yield AuthenticationAuthenticated(authenticate: event.authenticate);
    } else if (event is LoggedOut) {
      yield AuthenticationLoading();
      await userRepository.deleteToken();
      yield AuthenticationUnauthenticated();
    }
  }
}
