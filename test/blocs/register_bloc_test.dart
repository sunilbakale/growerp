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
  RegisterBloc registerBloc;

  setUp(() {
    mockReposRepository = MockReposRepository();
    mockAuthBloc = MockAuthBloc();
  });
  
  tearDown(() {
    mockAuthBloc?.close();
  });

  group('Register bloc test', () {

    blocTest( 'check initial state',
      build: () async => RegisterBloc(authBloc: mockAuthBloc, repos: mockReposRepository),
      expect: <AuthState> [],
    );

    blocTest(
      'Register success',
      build: () async => RegisterBloc(authBloc: mockAuthBloc, repos: mockReposRepository),
      act: (bloc) async {
        when(mockReposRepository.getCurrencies())
          .thenAnswer((_) async => currencyList);
        when(mockReposRepository.register(
          companyName: companyName, currency: currencyId,
          firstName: firstName, lastName: lastName, email: email))
          .thenAnswer((_) async => authenticate);
        bloc.add(LoadRegister());
        bloc.add(RegisterButtonPressed(
          companyName: companyName, currency: currencyId,
          firstName: firstName, lastName: lastName, email: email));
      },
      expect: <RegisterState>[ 
          RegisterLoading(),  // RegisterLoaded(currencies), 
          RegisterSubmitting(), RegisterSuccess()
      ],
    );
    blocTest(
      'Register Failure',
      build: () async => RegisterBloc(authBloc: mockAuthBloc, repos: mockReposRepository),
      act: (bloc) async {
        when(mockReposRepository.getCurrencies())
          .thenAnswer((_) async => errorMessage);
        when(mockReposRepository.register(
          companyName: companyName, currency: currencyId,
          firstName: firstName, lastName: lastName, email: email))
          .thenAnswer((_) async => errorMessage);
        bloc.add(LoadRegister());
        bloc.add(RegisterButtonPressed(
          companyName: companyName, currency: currencyId,
          firstName: firstName, lastName: lastName, email: email));
        whenListen(mockAuthBloc, Stream.fromIterable(<AuthEvent>[LoggedIn(authenticate: authenticate)]));
      },
      expect: <RegisterState>[ 
          RegisterLoading(), RegisterError(errorMessage: errorMessage),
          RegisterSubmitting(), RegisterError(errorMessage: errorMessage)
      ],
    );
  });

}
