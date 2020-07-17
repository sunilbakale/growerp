import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/@bloc.dart';
import 'services/repos.dart';
import 'styles/themes.dart';
import 'router.dart' as router;
import 'forms/@forms.dart';

void main() {
  Bloc.observer = SimpleBlocObserver();
  final repos = Repos();
  runApp(RepositoryProvider(
    create: (context) => Repos(),
    child: MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(repos: repos)..add(StartAuth())),
        BlocProvider<CatalogBloc>(
            create: (context) => CatalogBloc(repos: repos)..add(LoadCatalog())),
        BlocProvider<CartBloc>(
            create: (context) => CartBloc(repos: repos)..add(LoadCart())),
      ],
      child: MyApp(),
    ),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: Themes.formTheme,
        onGenerateRoute: router.generateRoute,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading || state is AuthInitial) {
              return SplashForm();
            } else
              return HomeForm();
          },
        ));
  }
}

class SimpleBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object event) {
    print("event: $event: ");
    super.onEvent(bloc, event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    print(transition);
    super.onTransition(bloc, transition);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stackTrace) {
    print("error: $error");
    super.onError(bloc, error, stackTrace);
  }
}
