import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';

import 'package:growerp/bloc/@bloc.dart';
import 'package:growerp/models/@models.dart';
import 'package:growerp/services/repos.dart';
import 'package:growerp/forms/@forms.dart';

class MockRepos extends Mock implements Repos {}
class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}
class MockLoginBloc extends MockBloc<String, String> implements LoginBloc {}

void main() {
  LoginBloc loginBloc;
  MockRepos repos;
  AuthBloc authBloc;
  setUp(() {
    repos = MockRepos();
    authBloc = MockAuthBloc();
    loginBloc = LoginBloc(
      repos: repos, 
      authBloc: AuthBloc(repos: repos));
  });

  tearDown(() {
    loginBloc?.close();
    authBloc?.close();
  });
  
  /*
  https://flutter.dev/docs/cookbook/testing/widget/tap-drag
  */
  group('login', () {
});
}
