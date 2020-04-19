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
      final connected = await userRepository.connected();
      if (!connected) {
        yield AuthenticationConnectionProblem();
      } else {
        final Authenticate authenticate = await userRepository.getAuthenticate();
        if (authenticate?.apiKey != null) {
          yield AuthenticationAuthenticated(authenticate: authenticate);
        } else {
          yield AuthenticationUnauthenticated(authenticate: authenticate);
        }
      }
    } else if (event is LoggedIn) {
      yield AuthenticationLoading();
      await userRepository.persistAuthenticate(event.authenticate);
      yield AuthenticationAuthenticated(authenticate: event.authenticate);
    } else if (event is LoggedOut) {
      yield AuthenticationLoading();
      final Authenticate authenticate = await userRepository.deleteApiKey();
      yield AuthenticationUnauthenticated(authenticate: authenticate);
    }
  }
}
