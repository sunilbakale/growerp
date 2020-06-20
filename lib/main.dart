import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'forms/@forms.dart';
import 'widgets/widgets.dart';
import 'bloc/@bloc.dart';
import 'services/repos.dart';
import 'styles/themes.dart';

void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  final repos = Repos();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(repos: repos)..add(AppStarted()),
        ),
        BlocProvider<CatalogBloc>(
          create: (context) => CatalogBloc(repos: repos)..add(LoadCatalog()),
        ),
        BlocProvider<CartBloc>(
          create: (context) => CartBloc(repos: repos)..add(LoadCart()),
        ),
      ],
      child: App(repos: repos),
    ),
  );
}

class App extends StatelessWidget {
  final Repos repos;

  App({Key key, @required this.repos})
      : assert(repos != null),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: Themes.formTheme,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthConnectionProblem || state is AuthHome) {
              return HomeForm();
            } else if (state is AuthUnauthenticated) {
              return HomeForm(authenticate: state.authenticate);
            } else if (state is AuthAuthenticated) {
              return HomeForm(authenticate: state.authenticate);
            } else if (state is AuthLogin) {
              return LoginForm(repos: repos, authenticate: state.authenticate);
            } else if (state is AuthRegister) {
              return RegisterForm(repos: repos);
            } else if (state is AuthChangePassword) {
              return ChangePwForm(
                username: state.username,
                oldPassword: state.oldPassword,
                repos: repos,
              );
            } else if (state is AuthLoading) {
              return LoadingIndicator();
            }
            return SplashForm();
          },
        ),
        routes: {
          '/details': (context) => ProductDetailsForm(),
          '/cart': (context) => CartForm(),
          '/about': (context) => AboutForm(),
        });
  }
}

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onEvent(Bloc bloc, Object event) {
    print('${bloc.runtimeType} event: $event');
    super.onEvent(bloc, event);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stackTrace) {
    print('${bloc.runtimeType} error: $error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    print('$transition');
    super.onTransition(bloc, transition);
  }
}
