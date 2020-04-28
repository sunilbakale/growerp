import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:mockito/mockito.dart';

import 'package:growerp/bloc/bloc.dart';
import 'package:growerp/models/models.dart';
import 'package:growerp/services/repos.dart';

class MockRepos extends Mock implements Repos {}
class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}
class AuthUnauthenticated extends AuthState {
  final Authenticate authenticate = authenticateFromJson('''
           {  "company": {"partyId": "000000",
                          "name": "dummyCompany",
                          "currency": "dummyCurrency"},
              "user": {"firstName": "dummyFirstName",
                       "lastName": "dummyLastName",
                       "email": "dummyEmail",
                       "name": "dummyEmail"},
              "apiKey": "dummyKey"}
      ''');
}

void main() {
  LoginBloc loginBloc;
  MockRepos repos;
  AuthBloc authBloc;
  final Authenticate authenticate = authenticateFromJson('''
           {  "company": {"partyId": "000000",
                          "name": "dummyCompany",
                          "currency": "dummyCurrency"},
              "user": {"firstName": "dummyFirstName",
                       "lastName": "dummyLastName",
                       "email": "dummyEmail",
                       "name": "dummyEmail"},
              "apiKey": "dummyKey"}
      ''');

  setUp(() {
    repos = MockRepos();
    authBloc = MockAuthBloc();
    loginBloc = LoginBloc(repos: repos, authBloc: AuthBloc(repos: repos));
  });

  tearDown(() {
    loginBloc?.close();
    authBloc?.close();
  });

  /*
  https://pub.dev/packages/bloc_test
  https://github.com/felangel/bloc/issues/721

  */
/*
  test('Login initial state should be FormBlocLoading', () {
    // whenListen(authBloc, Stream.fromIterable([AuthUnauthenticated(authenticate: authenticate)]));
    expect(loginBloc.initialState, FormBlocLoading(progress: 0.0));
  });

  test('Login close does not emit new states', () {
    expectLater(loginBloc, emitsInOrder([FormBlocLoading(progress: 1.0), emitsDone]),
    );
    loginBloc.close();
  });
*/

  group('login', () {
    test('emits [Loading, Loaded]', () {
      final expectedResponse = [FormBlocLoading,FormBlocLoading, FormBlocLoaded];
      whenListen( authBloc,
        Stream.fromIterable([
          AuthUninitialized(),
          AuthUnauthenticated()
        ])
      );
      when (repos.login(username: 'dummmy', password: 'dummy'))
        .thenAnswer((_) => Future.value(authenticate));

      expectLater(loginBloc, emitsInOrder(expectedResponse));

      loginBloc.add(LoadFormBloc());
    });
  });
}
