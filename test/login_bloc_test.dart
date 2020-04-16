import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:growerp/bloc/bloc.dart';
import 'package:growerp/models/models.dart';
import 'package:growerp/services/user_repository.dart';

class MockRepository extends Mock implements UserRepository {}

void main() {
  LoginBloc loginBloc;
  MockRepository mockRepository;

  setUp(() {
    mockRepository = MockRepository();
    loginBloc = LoginBloc(
      userRepository: mockRepository, 
      authenticationBloc: 
      AuthenticationBloc(userRepository: mockRepository));
  });

  tearDown(() {
    loginBloc?.close();
  });

  test('should assert if authenticationBloc null', () {
    expect(
      () => LoginBloc(userRepository: mockRepository, 
      authenticationBloc: null),
      throwsA(isAssertionError),
    );
  });
  test('should assert if repository null', () {
    expect(
      () => LoginBloc(userRepository: null, 
      authenticationBloc: AuthenticationBloc(userRepository: mockRepository)),
      throwsA(isAssertionError),
    );
  });
}