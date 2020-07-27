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

class MockAuthBloc extends MockBloc<AuthState> implements AuthBloc {}

class MockRegisterBloc extends MockBloc<RegisterState> implements RegisterBloc {
}

void main() {
  group('Register_Form', () {
    Repos repos;
    RegisterBloc registerBloc;
    AuthBloc authBloc;

    setUp(() {
      repos = MockRepos();
      authBloc = MockAuthBloc();
      registerBloc = MockRegisterBloc();
    });

    tearDown(() {
      registerBloc.close();
      authBloc.close();
    });

    testWidgets('check form text fields + Load register event',
        (WidgetTester tester) async {
      when(authBloc.state).thenReturn(AuthUnauthenticated(null));
      //     when(registerBloc.state).thenReturn(RegisterLoaded(currencies));
      // TODO: look like cannot mock registerblock so feed over repos
      when(repos.getCurrencies()).thenAnswer((_) async => currencies);
      when(repos.getCompanies()).thenAnswer((_) async => companies);
      await tester.pumpWidget(RepositoryProvider(
          create: (context) => repos,
          child: BlocProvider<AuthBloc>.value(
            value: authBloc,
            child: BlocProvider<RegisterBloc>.value(
              value: registerBloc,
              child: MaterialApp(
                onGenerateRoute: router.generateRoute,
                home: Scaffold(
                  body: RegisterForm(),
                ),
              ),
            ),
          )));
      await tester.pumpAndSettle();
      expect(find.text('Register a new company and admin'), findsWidgets);
      expect(find.byKey(Key('firstName')), findsOneWidget);
      expect(find.byKey(Key('lastName')), findsOneWidget);
      expect(find.byKey(Key('dropDown')), findsOneWidget);
      expect(find.byKey(Key('companyName')), findsOneWidget);
      expect(find.text('A temporary password will be send by email'),
          findsOneWidget);
      expect(find.byKey(Key('email')), findsOneWidget);
      expect(find.text('Currency'), findsWidgets);
      expect(find.byKey(Key('newCompany')), findsOneWidget);
    });

    testWidgets('RegisterForm enter fields and press register',
        (WidgetTester tester) async {
      when(repos.getCurrencies()).thenAnswer((_) async => currencies);
      when(authBloc.state).thenReturn(AuthUnauthenticated(null));
      await tester.pumpWidget(RepositoryProvider(
          create: (context) => repos,
          child: BlocProvider<AuthBloc>.value(
            value: authBloc,
            child: BlocProvider<RegisterBloc>.value(
              value: registerBloc,
              child: MaterialApp(
                onGenerateRoute: router.generateRoute,
                home: Scaffold(
                  body: RegisterForm(),
                ),
              ),
            ),
          )));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(Key('companyName')), companyName);
//      await tester.enterText(find.byType(DropdownButton), currencies[2]);
      await tester.enterText(find.byKey(Key('firstName')), username);
      await tester.enterText(find.byKey(Key('lastName')), password);
      await tester.enterText(find.byKey(Key('email')), email);
      await tester.tap(find.byKey(Key('newCompany')));
      await tester.pumpAndSettle();
      whenListen(
          registerBloc,
          Stream.fromIterable(<RegisterEvent>[
            LoadRegister(),
            CreateShopButtonPressed(
                companyName: companyName,
                currency: currencyId,
                firstName: firstName,
                lastName: lastName,
                email: email)
          ]));
    });
  });
}
