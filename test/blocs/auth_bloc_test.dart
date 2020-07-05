import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:growerp/bloc/@bloc.dart';
import 'package:growerp/services/repos.dart';
import '../data.dart';

class MockReposRepository extends Mock implements Repos {}

void main() {
  MockReposRepository mockReposRepository;

  setUp(() {
    mockReposRepository = MockReposRepository();
  });

  group('Authbloc test', () {
    blocTest(
      'check initial state',
      build: () async => AuthBloc(repos: mockReposRepository),
      expect: <AuthState>[],
    );

    blocTest<AuthBloc, AuthEvent, AuthState>(
      'succesful connection and Unauthenticated',
      build: () async => AuthBloc(repos: mockReposRepository),
      act: (bloc) async {
        when(mockReposRepository.getConnected()).thenAnswer((_) async => true);
        when(mockReposRepository.getAuthenticate())
            .thenAnswer((_) async => authenticateNoKey);
        bloc.add(StartAuth());
      },
      expect: <AuthState>[
        AuthLoading(),
        AuthUnauthenticated(authenticateNoKey),
      ],
    );
    blocTest(
      'failed connection with ConnectionProblem',
      build: () async => AuthBloc(repos: mockReposRepository),
      act: (bloc) async {
        when(mockReposRepository.getConnected())
            .thenAnswer((_) async => errorMessage);
        bloc.add(StartAuth());
      },
      expect: <AuthState>[
        AuthLoading(),
        AuthConnectionProblem(errorMessage),
      ],
    );

    blocTest(
      'succesfull connection and Authenticated',
      build: () async => AuthBloc(repos: mockReposRepository),
      act: (bloc) async {
        when(mockReposRepository.getConnected()).thenAnswer((_) async => true);
        when(mockReposRepository.getAuthenticate())
            .thenAnswer((_) async => authenticate);
        authenticate.apiKey = 'dummyKey';
        bloc.add(StartAuth());
      },
      expect: <AuthState>[
        AuthLoading(),
        AuthAuthenticated(authenticate),
      ],
    );
    blocTest(
      'connection and login and logout',
      build: () async => AuthBloc(repos: mockReposRepository),
      act: (bloc) async {
        when(mockReposRepository.getConnected()).thenAnswer((_) async => true);
        when(mockReposRepository.getAuthenticate())
            .thenAnswer((_) async => authenticateNoKey);
        when(mockReposRepository.logout())
            .thenAnswer((_) async => authenticateNoKey);
        bloc.add(StartAuth());
        bloc.add(LoggedIn(authenticate: authenticate));
        bloc.add(Logout());
      },
      expect: <AuthState>[
        AuthLoading(),
        AuthUnauthenticated(authenticateNoKey),
        AuthAuthenticated(authenticate),
        AuthUnauthenticated(authenticateNoKey),
      ],
    );
    blocTest(
      'succesful connection and register',
      build: () async => AuthBloc(repos: mockReposRepository),
      act: (bloc) async {
        when(mockReposRepository.getConnected()).thenAnswer((_) async => true);
        when(mockReposRepository.getAuthenticate())
            .thenAnswer((_) async => authenticateNoKey);
        bloc.add(StartAuth());
        bloc.add(LoggedIn(authenticate: authenticate));
      },
      expect: <AuthState>[
        AuthLoading(),
        AuthUnauthenticated(authenticateNoKey),
        AuthAuthenticated(authenticate),
      ],
    );

    dynamic result = Response;
    blocTest(
      'succesful connection login screen and reset password',
      build: () async => AuthBloc(repos: mockReposRepository),
      act: (bloc) async {
        when(mockReposRepository.getConnected()).thenAnswer((_) async => true);
        when(mockReposRepository.getAuthenticate())
            .thenAnswer((_) async => authenticateNoKey);
        when(mockReposRepository.resetPassword(username: 'dummyEmail'))
            .thenAnswer((_) async => result);
        bloc.add(StartAuth());
        await bloc.add(ResetPassword(username: 'dummyEmail'));
      },
      expect: <AuthState>[
        AuthLoading(),
        AuthUnauthenticated(authenticateNoKey),
      ],
    );
  });
}
