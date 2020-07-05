import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:growerp/bloc/@bloc.dart';
import 'package:growerp/services/repos.dart';
import 'package:growerp/forms/@forms.dart';
import '../data.dart';

class MockRepos extends Mock implements Repos {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockLoginBloc extends MockBloc<LoginEvent, LoginState>
    implements LoginBloc {}

void main() {
  group('Login_Form', () {
    Repos repos;
    LoginBloc loginBloc;
    AuthBloc authBloc;

    setUp(() {
      repos = MockRepos();
      authBloc = MockAuthBloc();
      loginBloc = MockLoginBloc();
    });

    tearDown(() {
      loginBloc?.close();
      authBloc?.close();
    });

    testWidgets('Login form text fields', (WidgetTester tester) async {
      await tester.pumpWidget(RepositoryProvider(
        create: (context) => repos,
        child: BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: MaterialApp(
            home: Scaffold(
              body: LoginForm(),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Login'), findsWidgets);
      expect(find.text('register new account'), findsOneWidget);
      expect(find.text('forgot password?'), findsOneWidget);
    });
    testWidgets('LoginForm enter fields and press login',
        (WidgetTester tester) async {
      await tester.pumpWidget(RepositoryProvider(
        create: (context) => repos,
        child: BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: MaterialApp(
            home: Scaffold(
              body: LoginForm(),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(Key('username')), username);
      await tester.enterText(find.byKey(Key('password')), password);
      await tester.tap(find.widgetWithText(RaisedButton, 'Login'));
      await tester.pumpAndSettle();

      whenListen(
          loginBloc,
          Stream.fromIterable(<LoginEvent>[
            LoginButtonPressed(username: username, password: password)
          ]));
    });
/*    testWidgets('LoginForm register, forgot password, go home at appbar',
        (WidgetTester tester) async {
      await tester.pumpWidget(RepositoryProvider(
        create: (context) => repos,
        child: BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: MaterialApp(
            home: Scaffold(
              body: LoginForm(),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      await tester
          .tap(find.widgetWithText(GestureDetector, 'register new account'));
      await tester
          .tap(find.widgetWithText(GestureDetector, 'forgot password?'));
      await tester.press(find.byKey(Key('goHome')));

      whenListen(
          loginBloc,
          Stream.fromIterable(<LoginEvent>[
            LoginButtonPressed(username: username), 
            ResetPassword(username: username)
          ]));

      whenListen(authBloc, Stream.fromIterable(<AuthEvent>[StartAuth()]));
    });
*/
    testWidgets('LoginForm forgot password modal', (WidgetTester tester) async {
      await tester.pumpWidget(RepositoryProvider(
        create: (context) => repos,
        child: BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: MaterialApp(
            home: Scaffold(
              body: LoginForm(),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('forgot password?'), findsOneWidget);
      await tester
          .tap(find.widgetWithText(GestureDetector, 'forgot password?'));
      await tester.pumpAndSettle();
      expect(
          find.text(
              'Email you registered with?\nWe will send you a reset password'),
          findsOneWidget);
      await tester.press(find.widgetWithText(FlatButton, 'Ok'));
      expect(find.text('forgot password?'), findsOneWidget);
    });
  });
}
