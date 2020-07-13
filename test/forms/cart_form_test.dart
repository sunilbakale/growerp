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

class MockCartBloc extends MockBloc<CartEvent, CartState> implements CartBloc {}

void main() {
  group('Cart_Form test:', () {
    Repos repos;
    CartBloc cartBloc;
    AuthBloc authBloc;

    setUp(() {
      repos = MockRepos();
      authBloc = MockAuthBloc();
      cartBloc = MockCartBloc();
    });

    tearDown(() {
      cartBloc?.close();
      authBloc?.close();
    });

    testWidgets('renders empty', (WidgetTester tester) async {
      when(authBloc.state).thenAnswer((_) => AuthUnauthenticated(null));
      when(cartBloc.state).thenAnswer((_) => CartLoaded(emptyOrder));
      await tester.pumpWidget(RepositoryProvider(
          create: (context) => repos,
          child: MultiBlocProvider(
              providers: [
                BlocProvider<AuthBloc>.value(value: authBloc),
                BlocProvider<CartBloc>.value(value: cartBloc),
              ],
              child: BlocProvider<CartBloc>.value(
                  value: cartBloc,
                  child: MaterialApp(
                      onGenerateRoute: router.generateRoute,
                      home: Scaffold(
                        body: CartForm(),
                      ))))));
      await tester.pumpAndSettle();
      expect(find.text('Cart'), findsOneWidget);
      expect(find.text('BUY'), findsOneWidget);
      expect(find.text('Quantity'), findsOneWidget);
      expect(find.text('Price'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
    });
    testWidgets('renders empty', (WidgetTester tester) async {
      when(authBloc.state).thenAnswer((_) => AuthUnauthenticated(null));
      when(cartBloc.state).thenAnswer((_) => CartLoaded(order));
      await tester.pumpWidget(RepositoryProvider(
          create: (context) => repos,
          child: MultiBlocProvider(
              providers: [
                BlocProvider<AuthBloc>.value(value: authBloc),
                BlocProvider<CartBloc>.value(value: cartBloc),
              ],
              child: BlocProvider<CartBloc>.value(
                  value: cartBloc,
                  child: MaterialApp(
                      onGenerateRoute: router.generateRoute,
                      home: Scaffold(
                        body: CartForm(),
                      ))))));
      await tester.pumpAndSettle();
      expect(find.text('Cart'), findsOneWidget);
      expect(find.text('Macaroni'), findsOneWidget);
      expect(find.text('Cola'), findsOneWidget);
    });
    testWidgets('renders empty', (WidgetTester tester) async {
      when(authBloc.state).thenAnswer((_) => AuthUnauthenticated(null));
      when(cartBloc.state).thenAnswer((_) => CartLoaded(order));
      await tester.pumpWidget(RepositoryProvider(
          create: (context) => repos,
          child: MultiBlocProvider(
              providers: [
                BlocProvider<AuthBloc>.value(value: authBloc),
                BlocProvider<CartBloc>.value(value: cartBloc),
              ],
              child: BlocProvider<CartBloc>.value(
                  value: cartBloc,
                  child: MaterialApp(
                      onGenerateRoute: router.generateRoute,
                      home: Scaffold(
                        body: CartForm(),
                      ))))));
      await tester.pumpAndSettle();
      expect(find.text('Cart'), findsOneWidget);
      await tester.tap(find.widgetWithText(RaisedButton, 'BUY'));
      await tester.pumpAndSettle();
      expect(find.text('Login'), findsWidgets); // should be 2?
    });
    testWidgets('renders empty', (WidgetTester tester) async {
      when(authBloc.state).thenAnswer((_) => AuthAuthenticated(authenticate));
      when(cartBloc.state).thenAnswer((_) => CartLoaded(order));
      await tester.pumpWidget(RepositoryProvider(
          create: (context) => repos,
          child: MultiBlocProvider(
              providers: [
                BlocProvider<AuthBloc>.value(value: authBloc),
                BlocProvider<CartBloc>.value(value: cartBloc),
              ],
              child: BlocProvider<CartBloc>.value(
                  value: cartBloc,
                  child: MaterialApp(
                      onGenerateRoute: router.generateRoute,
                      home: Scaffold(
                        body: CartForm(),
                      ))))));
      await tester.pumpAndSettle();
      expect(find.text('Cart'), findsOneWidget);
      await tester.tap(find.widgetWithText(RaisedButton, 'BUY'));
      await tester.pumpAndSettle();
      whenListen(cartBloc, Stream.fromIterable(<CartEvent>[PayOrder(order)]));
    });
  });
}