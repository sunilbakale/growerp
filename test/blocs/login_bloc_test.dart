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
  MockAuthBloc authBloc;

  setUp(() {
    mockReposRepository = MockReposRepository();
    authBloc = MockAuthBloc();
  });

  tearDown(() {
    authBloc?.close();
  });

  group('Login bloc test', () {
    blocTest(
      'check initial state',
      build: () async => LoginBloc(repos: mockReposRepository),
      expect: <AuthState>[],
    );

    blocTest('Login success',
        build: () async => LoginBloc(repos: mockReposRepository),
        act: (bloc) async {
          when(mockReposRepository.login(username: email, password: password))
              .thenAnswer((_) async => authenticate);
          bloc.add(LoginButtonPressed(username: email, password: password));
          whenListen(
              authBloc,
              Stream.fromIterable(
                  <AuthEvent>[LoggedIn(authenticate: authenticate)]));
        },
        expect: <LoginState>[
          LoginInProgress(),
          LoginOk(authenticate: authenticate)
        ]);

    blocTest(
      'Login failure',
      build: () async => LoginBloc(repos: mockReposRepository),
      act: (bloc) async {
        when(mockReposRepository.login(username: username, password: password))
            .thenAnswer((_) async => errorMessage);
        bloc.add(LoginButtonPressed(username: username, password: password));
      },
      expect: <LoginState>[
        LoginInProgress(),
        LoginFailure(error: errorMessage)
      ],
    );

    blocTest(
      'Login succes and change password',
      build: () async => LoginBloc(repos: mockReposRepository),
      act: (bloc) async {
        when(mockReposRepository.login(username: username, password: password))
            .thenAnswer((_) async => "passwordChange");
        bloc.add(LoginButtonPressed(username: username, password: password));
        whenListen(
            authBloc,
            Stream.fromIterable(
                <AuthEvent>[LoggedIn(authenticate: authenticate)]));
      },
      expect: <LoginState>[
        LoginInProgress(),
        LoginChangePw(username: username, password: password),
      ],
    );
  });
}
