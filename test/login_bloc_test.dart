import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:growerp/bloc/bloc.dart';
import 'package:growerp/models/models.dart';
import 'package:growerp/services/repos.dart';

class MockRepository extends Mock implements Repos {}

void main() {
  LoginBloc loginBloc;
  MockRepository mockRepository;

  setUp(() {
    mockRepository = MockRepository();
    loginBloc = LoginBloc(
      repos: mockRepository, 
      authBloc: 
      AuthBloc(repos: mockRepository));
  });

  tearDown(() {
    loginBloc?.close();
  });

  test('should assert if authBloc null', () {
    expect(
      () => LoginBloc(repos: mockRepository, 
      authBloc: null),
      throwsA(isAssertionError),
    );
  });
  test('should assert if repository null', () {
    expect(
      () => LoginBloc(repos: null, 
      authBloc: AuthBloc(repos: mockRepository)),
      throwsA(isAssertionError),
    );
  });
}