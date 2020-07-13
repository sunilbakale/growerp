import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:growerp/bloc/@bloc.dart';
import 'package:growerp/services/repos.dart';
import 'package:growerp/forms/@forms.dart';
import 'package:growerp/router.dart' as router;
import '../data.dart';

class MockRepos extends Mock implements Repos {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockRegisterBloc extends MockBloc<RegisterEvent, RegisterState>
    implements RegisterBloc {}

class MockCatalogBloc extends MockBloc<RegisterEvent, RegisterState>
    implements CatalogBloc {}

void main() {
  group('Register_Form', () {
    Repos repos;
    RegisterBloc registerBloc;
    CatalogBloc catalogBloc;

    setUp(() {
      repos = MockRepos();
      catalogBloc = MockCatalogBloc();
      registerBloc = MockRegisterBloc();
    });

    tearDown(() {
      registerBloc?.close();
      catalogBloc?.close();
    });

    testWidgets('check form text fields + Load register event',
        (WidgetTester tester) async {
//      when(catalogBloc.state).thenAnswer((_) => CatalogLoaded(catalog));
//      when(registerBloc.state).thenAnswer((_) => RegisterLoaded(currencies));
      await tester.pumpWidget(RepositoryProvider(
        create: (context) => repos,
        child: BlocProvider<CatalogBloc>.value(
          value: catalogBloc,
          child: MaterialApp(
            onGenerateRoute: router.generateRoute,
            home: Scaffold(
              body: RegisterForm(),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
//      expect(find.text('A temporary password will be send by email'),
//          findsOneWidget);
//      expect(find.text('Register'), findsWidgets);
//      whenListen(
//          registerBloc, Stream.fromIterable(<RegisterEvent>[LoadRegister()]));
    });
/*    testWidgets('RegisterForm enter fields and press register',
        (WidgetTester tester) async {
      when(registerBloc.state).thenReturn(RegisterLoaded(currencies));
      await tester.pumpWidget(RepositoryProvider(
        create: (context) => repos,
        child: BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: MaterialApp(
            home: Scaffold(
              body: RegisterForm(),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(Key('companyName')), companyName);
//      await tester.enterText(find.byType(DropdownButton), currencyId);
      await tester.enterText(find.byKey(Key('firstName')), username);
      await tester.enterText(find.byKey(Key('lastName')), password);
      await tester.enterText(find.byKey(Key('email')), email);
      await tester.tap(find.widgetWithText(RaisedButton, 'Register'));
      await tester.pumpAndSettle();
      whenListen(
          registerBloc,
          Stream.fromIterable(<RegisterEvent>[
            LoadRegister(),
            RegisterButtonPressed(
                companyPartyId: companyPartyId,
                firstName: firstName,
                lastName: lastName,
                email: email)
          ]));
    });

    testWidgets('RegisterForm register, forgot password ',
        (WidgetTester tester) async {
      await tester.pumpWidget(RepositoryProvider(
        create: (context) => repos,
        child: BlocProvider<CatalogBloc>.value(
          value: catalogBloc,
          child: MaterialApp(
            home: Scaffold(
              body: RegisterForm(),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      whenListen(registerBloc,
          Stream.fromIterable(<AuthEvent>[ResetPassword(username: username)]));
    });
*/
  });
}
