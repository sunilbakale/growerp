import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:hotel/blocs/@blocs.dart';
import 'package:hotel/services/repos.dart';
import '../data.dart';

class MockReposRepository extends Mock implements Repos {}

class MockAuthBloc extends MockBloc<AuthState> implements AuthBloc {}

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
      build: () => LoginBloc(repos: mockReposRepository),
      expect: <AuthState>[],
    );

    blocTest('Login success',
        build: () => LoginBloc(repos: mockReposRepository),
        act: (bloc) async {
          when(mockReposRepository.login(
                  companyPartyId: companyPartyId,
                  username: email,
                  password: password))
              .thenAnswer((_) async => authenticate);
          bloc.add(LoginButtonPressed(
              companyPartyId: companyPartyId,
              username: email,
              password: password));
          whenListen(
              authBloc,
              Stream.fromIterable(
                  <AuthEvent>[LoggedIn(authenticate: authenticate)]));
        },
        expect: <LoginState>[LogginInProgress(), LoginOk(authenticate)]);

    blocTest(
      'Login failure',
      build: () => LoginBloc(repos: mockReposRepository),
      act: (bloc) async {
        when(mockReposRepository.login(
                companyPartyId: companyPartyId,
                username: username,
                password: password))
            .thenAnswer((_) async => errorMessage);
        bloc.add(LoginButtonPressed(
            companyPartyId: companyPartyId,
            username: username,
            password: password));
      },
      expect: <LoginState>[LogginInProgress(), LoginError(errorMessage)],
    );

    blocTest(
      'Login succes and change password',
      build: () => LoginBloc(repos: mockReposRepository),
      act: (bloc) async {
        when(mockReposRepository.login(
                companyPartyId: companyPartyId,
                username: username,
                password: password))
            .thenAnswer((_) async => "passwordChange");
        bloc.add(LoginButtonPressed(
            companyPartyId: companyPartyId,
            username: username,
            password: password));
        whenListen(
            authBloc,
            Stream.fromIterable(
                <AuthEvent>[LoggedIn(authenticate: authenticate)]));
      },
      expect: <LoginState>[
        LogginInProgress(),
        LoginChangePw(username, password),
      ],
    );
  });
}
