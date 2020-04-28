import 'dart:ffi';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:growerp/bloc/bloc.dart';
import 'package:growerp/models/models.dart';
import 'package:growerp/services/repos.dart';

class MockRepository extends Mock implements Repos {}

void main() {
  AuthBloc authBloc;
  MockRepository repos;
  final Authenticate authenticate = authenticateFromJson('''
           {  "company": {"name": "dummyCompany",
                          "currency": "dummyCurrency"},
              "user": {"firstName": "dummyFirstName",
                       "lastName": "dummyLastName",
                       "email": "dummyEmail",
                       "name": "dummyEmail"},
              "apiKey": "dummyKey"}
      ''');

  setUp(() {
    repos = MockRepository();
    authBloc = AuthBloc(repos: repos);
  });

  tearDown(() {
    authBloc?.close();
  });

  test('Auth: should assert if repository null', () {
    expect(
      () => AuthBloc(repos: null),
      throwsA(isAssertionError),
    );
  });

  test('Auth initial state should be AuthUninitialized', () {
    expect(authBloc.initialState, AuthUninitialized());
  });

  test('Auth close does not emit new states', () {
    expectLater(authBloc, emitsInOrder([AuthUninitialized(), emitsDone]));
    authBloc.close();
  });
  
  group('AppStarted', () {
    test('emits [uninitialized, connectionProblem] for exception getting token',
        () {
      final expectedResponse = [AuthUninitialized(), AuthConnectionProblem()];

      when(repos.connected()).thenAnswer((_) => Future.value(false));

      expectLater(authBloc, emitsInOrder(expectedResponse));

      authBloc.add(AppStarted());
    });
  });

  group('AppStarted', () {
    test('emits [uninitialized, unauthenticated] for missing token', () {
      final expectedResponse = [AuthUninitialized(), AuthUnauthenticated()];

      when(repos.connected()).thenAnswer((_) => Future.value(true));
      when(repos.getAuthenticate()).thenAnswer((_) => Future.value(null));

      expectLater(authBloc, emitsInOrder(expectedResponse));

      authBloc.add(AppStarted());
    });
  });

  group('AppStarted', () {
    test('emits [uninitialized, authenticated] with token', () {
      final expectedResponse = [
        AuthUninitialized(),
        AuthAuthenticated(authenticate: authenticate)
      ];

      when(repos.connected()).thenAnswer((_) => Future.value(true));
      when(repos.getAuthenticate())
          .thenAnswer((_) => Future.value(authenticate));

      expectLater(authBloc, emitsInOrder(expectedResponse));

      authBloc.add(AppStarted());
    });
  });

  group('LoggedIn', () {
    test('emits [uninitialized, loading, authenticated]', () {
      final expectedResponse = [
        AuthUninitialized(),
        AuthLoading(),
        AuthAuthenticated(authenticate: authenticate),
      ];

      when(repos.persistAuthenticate(authenticate))
          .thenAnswer((_) => Future.value(Void));

      expectLater(authBloc, emitsInOrder(expectedResponse));

      authBloc.add(LoggedIn(authenticate: authenticate));
    });
  });

  group('LoggedOut', () {
    test('emits [uninitialized, loading, unauthenticated]', () {
      final expectedResponse = [
        AuthUninitialized(),
        AuthLoading(),
        AuthUnauthenticated(authenticate: authenticate),
      ];

      when(repos.logout()).thenAnswer((_) => Future.value(Void));
      when(repos.getAuthenticate())
          .thenAnswer((_) => Future.value(authenticate));
      when(repos.persistAuthenticate(authenticate))
          .thenAnswer((_) => Future.value(Void));

      expectLater(authBloc, emitsInOrder(expectedResponse));

      authBloc.add(LoggedOut());
    });
  });

  group('Register', () {
    test('emits [uninitialized, register]', () {
      final expectedResponse = [AuthUninitialized(), AuthRegister()];

      expectLater(authBloc, emitsInOrder(expectedResponse));

      authBloc.add(Register());
    });
  });
}
