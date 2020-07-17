import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:growerp/blocs/@bloc.dart';
import 'package:growerp/services/repos.dart';
import 'package:growerp/forms/@forms.dart';
import 'package:growerp/router.dart' as router;
import '../data.dart';

class MockRepos extends Mock implements Repos {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockLoginBloc extends MockBloc<LoginEvent, LoginState>
    implements LoginBloc {}

void main() {
  group('Login_Form test:', () {
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

    testWidgets('check text fields', (WidgetTester tester) async {
      when(authBloc.state).thenReturn(AuthUnauthenticated(authenticateNoKey));
//      when(loginBloc.state).thenReturn(LoginLoaded(companies));
      when(repos.getCompanies()).thenAnswer((_) async => companies);
      await tester.pumpWidget(RepositoryProvider(
          create: (context) => repos,
          child: BlocProvider.value(
            value: authBloc,
            child: BlocProvider.value(
              value: loginBloc,
              child: MaterialApp(
                onGenerateRoute: router.generateRoute,
                home: Scaffold(
                  body: LoginForm(),
                ),
              ),
            ),
          )));
      await tester.pumpAndSettle();
      expect(find.text(companies[0].name), findsOneWidget);
      expect(find.byKey(Key('username')), findsOneWidget);
      expect(find.byKey(Key('password')), findsOneWidget);
      expect(find.text('Login'), findsWidgets);
      expect(find.text('register new account'), findsOneWidget);
      expect(find.text('forgot password?'), findsOneWidget);
      whenListen(loginBloc, Stream.fromIterable(<LoginEvent>[LoadLogin()]));
    });
    testWidgets('enter fields and press login', (WidgetTester tester) async {
      when(authBloc.state).thenReturn(AuthUnauthenticated(authenticateNoKey));
//      when(loginBloc.state).thenReturn(LoginLoaded(companies));
      when(repos.getCompanies()).thenAnswer((_) async => companies);
      await tester.pumpWidget(RepositoryProvider(
          create: (context) => repos,
          child: BlocProvider.value(
            value: authBloc,
            child: BlocProvider.value(
              value: loginBloc,
              child: MaterialApp(
                onGenerateRoute: router.generateRoute,
                home: Scaffold(
                  body: LoginForm(),
                ),
              ),
            ),
          )));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(Key('username')), username);
      await tester.enterText(find.byKey(Key('password')), password);
      await tester.tap(find.widgetWithText(RaisedButton, 'Login'));
      await tester.pumpAndSettle();

      whenListen(
          loginBloc,
          Stream.fromIterable(<LoginEvent>[
            LoginButtonPressed(
                companyPartyId: companyPartyId,
                username: username,
                password: password)
          ]));
    });
    testWidgets('register', (WidgetTester tester) async {
      when(authBloc.state).thenReturn(AuthUnauthenticated(authenticateNoKey));
//      when(loginBloc.state).thenReturn(LoginLoaded(companies));
      when(repos.getCompanies()).thenAnswer((_) async => companies);
      when(repos.getCurrencies()).thenAnswer((_) async => currencies);
      await tester.pumpWidget(RepositoryProvider(
          create: (context) => repos,
          child: BlocProvider.value(
            value: authBloc,
            child: BlocProvider.value(
              value: loginBloc,
              child: MaterialApp(
                onGenerateRoute: router.generateRoute,
                home: Scaffold(
                  body: LoginForm(),
                ),
              ),
            ),
          )));
      await tester.pumpAndSettle();
      await tester
          .tap(find.widgetWithText(GestureDetector, 'register new account'));
      await tester.pumpAndSettle();
      expect(
          find.text('Register AND create new Ecommerce shop'), findsOneWidget);
    });
    testWidgets('forgot password', (WidgetTester tester) async {
      when(authBloc.state).thenReturn(AuthUnauthenticated(authenticateNoKey));
//      when(loginBloc.state).thenReturn(LoginLoaded(companies));
      when(repos.getCompanies()).thenAnswer((_) async => companies);
      when(repos.getCurrencies()).thenAnswer((_) async => currencies);
      await tester.pumpWidget(RepositoryProvider(
          create: (context) => repos,
          child: BlocProvider.value(
            value: authBloc,
            child: BlocProvider.value(
              value: loginBloc,
              child: MaterialApp(
                onGenerateRoute: router.generateRoute,
                home: Scaffold(
                  body: LoginForm(),
                ),
              ),
            ),
          )));
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
