import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:growerp/bloc/@bloc.dart';
import 'package:growerp/services/repos.dart';
import '../data.dart';

class MockReposRepository extends Mock implements Repos {}
class MockAuthBloc extends MockBloc<AuthEvent, int> implements AuthBloc {}

void main() {
  MockReposRepository mockReposRepository;

  setUp(() {
    mockReposRepository = MockReposRepository();
  });

  group('Authbloc test', () {

    blocTest( 'check initial state',
      build: () async => AuthBloc(repos: mockReposRepository),
      expect: <AuthState> [],
    );

    blocTest<AuthBloc, AuthEvent, AuthState>(
      'succesful connection and Unauthenticated',
      build: () async => AuthBloc(repos: mockReposRepository),
      act: (bloc) async {
        when(mockReposRepository.getConnected())
          .thenAnswer((_) async => true);
        when(mockReposRepository.getAuthenticate())
          .thenAnswer((_) async => authenticateNoKey);
        bloc.add(AppStarted());
      },
      expect: <AuthState>[
        AuthLoading(),
        AuthUnauthenticated(authenticate: authenticateNoKey),
      ],
    );
    blocTest('failed connection with ConnectionProblem',
      build: () async => AuthBloc(repos: mockReposRepository),
      act: (bloc) async {
        when(mockReposRepository.getConnected()).thenAnswer((_) async => errorMessage);
        bloc.add(AppStarted());
      },
      expect: <AuthState>[
        AuthLoading(),
        AuthConnectionProblem(errorMessage: errorMessage),
      ],
    );
  
    blocTest('succesfull connection and Authenticated',
      build: () async => AuthBloc(repos: mockReposRepository),
      act: (bloc) async {
        when(mockReposRepository.getConnected()).thenAnswer((_) async => true);
        when(mockReposRepository.getAuthenticate()).thenAnswer((_) async => authenticate);
        authenticate.apiKey = 'dummyKey';
        bloc.add(AppStarted());
      },
      expect: <AuthState>[
        AuthLoading(),
        AuthAuthenticated(authenticate: authenticate),
      ],
    );
    blocTest('connection and login and logout',
      build: () async => AuthBloc(repos: mockReposRepository),
      act: (bloc) async {
        when(mockReposRepository.getConnected())
          .thenAnswer((_) async => true);
        when(mockReposRepository.getAuthenticate())
          .thenAnswer((_) async => authenticateNoKey);
        bloc.add(AppStarted());
        bloc.add(Login());
        bloc.add(LoggedIn(authenticate: authenticate));
        bloc.add(Logout());
      },
      expect: <AuthState>[
        AuthLoading(),
        AuthUnauthenticated(authenticate: authenticateNoKey),
        AuthLogin(authenticate: authenticate),
        AuthAuthenticated(authenticate: authenticate),
        AuthUnauthenticated(),
      ],
    );
    blocTest(
      'succesful connection and register',
      build: () async => AuthBloc(repos: mockReposRepository),
      act: (bloc) async {
        when(mockReposRepository.getConnected())
          .thenAnswer((_) async => true);
        when(mockReposRepository.getAuthenticate())
          .thenAnswer((_) async => authenticateNoKey);
        bloc.add(AppStarted());
        bloc.add(Register());
        bloc.add(Login());
      },
      expect: <AuthState>[
        AuthLoading(),
        AuthUnauthenticated(authenticate: authenticateNoKey),
        AuthRegister(),
        AuthLogin(authenticate: authenticateNoKey),
      ],
    );
    blocTest(
      'succesful connection and change password',
      build: () async => AuthBloc(repos: mockReposRepository),
      act: (bloc) async {
        when(mockReposRepository.getConnected())
          .thenAnswer((_) async => true);
        when(mockReposRepository.getAuthenticate())
          .thenAnswer((_) async => authenticateNoKey);
        bloc.add(AppStarted());
        bloc.add(ChangePassword(username: 'dummyEmail', oldPassword: 'dummyPassword'));
        bloc.add(Login());
      },
      expect: <AuthState>[
        AuthLoading(),
        AuthUnauthenticated(authenticate: authenticateNoKey),
        AuthChangePassword(username: 'dummyEmail', oldPassword: 'dummyPassword'),
        AuthLogin(authenticate: authenticateNoKey),
      ],
    );

    dynamic result = Response;
    blocTest(
      'succesful connection login screen and reset password',
      build: () async => AuthBloc(repos: mockReposRepository),
      act: (bloc) async {
        when(mockReposRepository.getConnected())
          .thenAnswer((_) async => true);
        when(mockReposRepository.getAuthenticate())
          .thenAnswer((_) async => authenticateNoKey);
        when(mockReposRepository.resetPassword(username: 'dummyEmail'))
          .thenAnswer((_) async => result);
        bloc.add(AppStarted());
        bloc.add(Login());
        await bloc.add(ResetPassword(username: 'dummyEmail'));
//        result = "error message";
        bloc.add(Login());
      },
      expect: <AuthState>[
        AuthLoading(),
        AuthUnauthenticated(authenticate: authenticateNoKey),
        AuthLogin(authenticate: authenticateNoKey),
        AuthLoading(),
        AuthLogin(authenticate: authenticateNoKey),
      ],
    );


  });
}
