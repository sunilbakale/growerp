import 'package:flutter/material.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:growerp/bloc/@bloc.dart';
import 'package:growerp/services/repos.dart';
import '../data.dart';

class MockReposRepository extends Mock implements Repos {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  WidgetsFlutterBinding.ensureInitialized(); 
  MockReposRepository mockReposRepository;
  MockAuthBloc mockAuthBloc;

  setUp(() {
    mockReposRepository = MockReposRepository();
    mockAuthBloc = MockAuthBloc();
  });

  tearDown(() {
    mockAuthBloc?.close();
  });

  group('ChangePassword bloc test', () {
    blocTest('check initial state',
        build: () async =>
            ChangePwBloc(authBloc: mockAuthBloc, repos: mockReposRepository),
        expect: <AuthState>[]);

    blocTest('ChangePw success',
        build: () async =>
            ChangePwBloc(authBloc: mockAuthBloc, repos: mockReposRepository),
        act: (bloc) async {
          when(mockReposRepository.updatePassword(
                  username: username,
                  oldPassword: password,
                  newPassword: password))
              .thenAnswer((_) async => authenticate);
          bloc.add(ChangePwButtonPressed(
              username: username, oldPassword: password, newPassword: password));
          whenListen(mockAuthBloc, Stream.fromIterable(<AuthEvent>[Login()]));
        },
        expect: <ChangePwState>[ChangePwInProgress()]
    );
// cannot run see: https://stackoverflow.com/questions/57689492/flutter-unhandled-exception-servicesbinding-defaultbinarymessenger-was-accesse
/*    blocTest('ChangePw failure',
        build: () async =>
            ChangePwBloc(authBloc: mockAuthBloc, repos: mockReposRepository),
        act: (bloc) async {
          when(mockReposRepository.updatePassword(
                  username: username,
                  oldPassword: password,
                  newPassword: password))
              .thenAnswer((_) async => errorMessage);
          bloc.add(ChangePwButtonPressed(
              username: username, oldPassword: password, newPassword: password));
          whenListen(mockAuthBloc, Stream.fromIterable(<AuthEvent>[Login()]));
        },
      expect: <ChangePwState>[
        ChangePwInProgress(),
        ChangePwFailure(message: errorMessage)
      ],
    );
*/  });
}
