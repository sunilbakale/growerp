import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:growerp/bloc/@bloc.dart';
import 'package:growerp/services/repos.dart';
import '../data.dart';

class MockReposRepository extends Mock implements Repos {}
class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  MockReposRepository mockReposRepository;
  MockAuthBloc mockAuthBloc;

  setUp(() {
    mockReposRepository = MockReposRepository();
    mockAuthBloc = MockAuthBloc();
  });
  
  tearDown(() {
    mockAuthBloc?.close();
  });

  group('Login bloc test', () {

    blocTest( 'check initial state',
      build: () async => LoginBloc(authBloc: mockAuthBloc, repos: mockReposRepository),
      expect: <AuthState> [],
    );

    blocTest(
      'Login success',
      build: () async => LoginBloc(authBloc: mockAuthBloc, repos: mockReposRepository),
      act: (bloc) async {
        when(mockReposRepository.login(username: email, password: password))
          .thenAnswer((_) async => authenticate);
        bloc.add(LoginButtonPressed(username: email, password: password));
        whenListen(mockAuthBloc, Stream.fromIterable(<AuthEvent>[LoggedIn(authenticate: authenticate)]));
      },
      expect: <LoginState>[
        LoginInProgress(),
      ],
    );

    blocTest(
      'Login failure',
      build: () async => LoginBloc(authBloc: mockAuthBloc, repos: mockReposRepository),
      act: (bloc) async {
        when(mockReposRepository.login(username: email, password: password))
          .thenAnswer((_) async => errorMessage);
        bloc.add(LoginButtonPressed(username: email, password: password));
        whenListen(mockAuthBloc, Stream.fromIterable(<AuthEvent>[]));
      },
      expect: <LoginState>[
        LoginInProgress(),
        LoginFailure(error: errorMessage)
      ],
    );

    blocTest(
      'Login succes and change password',
      build: () async => LoginBloc(authBloc: mockAuthBloc, repos: mockReposRepository),
      act: (bloc) async {
        when(mockReposRepository.login(username: email, password: password))
          .thenAnswer((_) async => "passwordChange");
        bloc.add(LoginButtonPressed(username: email, password: password));
        whenListen(mockAuthBloc, Stream.fromIterable(<AuthEvent>[
          ChangePassword(username: email, oldPassword: password)]));
      },
      expect: <LoginState>[
        LoginInProgress(),
      ],
    );

  });

}
