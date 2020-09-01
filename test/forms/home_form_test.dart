import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:ecommerce/blocs/@blocs.dart';
import 'package:ecommerce/forms/@forms.dart';
import 'package:ecommerce/router.dart' as router;
import '../data.dart';

class MockAuthBloc extends MockBloc<AuthState> implements AuthBloc {}

class MockCatalogBloc extends MockBloc<CatalogState> implements CatalogBloc {}

class MockCartBloc extends MockBloc<CartState> implements CartBloc {}

void main() {
  group('Home_Form test:', () {
    CatalogBloc catalogBloc;
    CartBloc cartBloc;
    AuthBloc authBloc;

    setUp(() {
      authBloc = MockAuthBloc();
      catalogBloc = MockCatalogBloc();
      cartBloc = MockCartBloc();
    });

    tearDown(() {
      catalogBloc?.close();
      cartBloc?.close();
      authBloc?.close();
    });

    testWidgets('renders with empty catalog not logged in',
        (WidgetTester tester) async {
      when(catalogBloc.state).thenReturn(CatalogLoaded(emptyCatalog));
      when(cartBloc.state).thenReturn(CartLoaded(emptyOrder));
      when(authBloc.state).thenReturn(AuthUnauthenticated(null));
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            BlocProvider<CatalogBloc>.value(value: catalogBloc),
            BlocProvider<CartBloc>.value(value: cartBloc),
          ],
          child: MaterialApp(
            onGenerateRoute: router.generateRoute,
            home: Scaffold(
              body: HomeForm(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('No categories found to display'), findsOneWidget);
    });
    testWidgets('render with catalog?', (WidgetTester tester) async {
      when(catalogBloc.state).thenAnswer((_) => CatalogLoaded(catalog));
      when(authBloc.state)
          .thenAnswer((_) => AuthUnauthenticated(authenticateNoKey));
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            BlocProvider<CatalogBloc>.value(value: catalogBloc),
            BlocProvider<CartBloc>.value(value: cartBloc),
          ],
          child: MaterialApp(
            onGenerateRoute: router.generateRoute,
            home: Scaffold(
              body: HomeForm(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('This is the first product'), findsOneWidget);
    });
  });
}
