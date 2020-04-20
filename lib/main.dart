import 'package:flutter/material.dart';
import 'package:growerp/styles/themes.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'services/repos.dart';

import 'bloc/auth/auth.dart';
import 'forms/forms.dart';
import 'widgets/widgets.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    print("===event: $event");
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print("===Transition: $transition");
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    print("===error: $error");
  }
}

void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  final repos = Repos();
  final authBloc = AuthBloc(repos: repos);

  runApp(
    BlocProvider<AuthBloc>(
      create: (context) {
        return AuthBloc(repos: repos)
          ..add(AppStarted());
      },
      child: App(repos: repos,
          authBloc: authBloc),
    ),
  );
}

Widget buildError(BuildContext context, FlutterErrorDetails error) {
   return Scaffold(
     body: Center(
       child: Text(
         "Error appeared.",
         style: Theme.of(context).textTheme.headline6,
       ),
     )
   );
 }
class App extends StatelessWidget {
  final Repos repos;
  final AuthBloc authBloc;

  App({Key key, @required this.repos,
                     @required this.authBloc})
    : assert(repos != null, authBloc != null),
    super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Themes.formTheme,
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthConnectionProblem) {
            return NoConnectionForm();
          } else if (state is AuthAuthenticated) {
            return HomeForm(repos: repos,
              authBloc: authBloc);
          } else if (state is AuthUnauthenticated) {
            return LoginForm(repos: repos,
              authBloc: authBloc);
          } else if (state is AuthLoading) {
            return LoadingIndicator();
          } else if (state is AuthRegister) {
            return RegisterForm(repos: repos);
          } else return SplashForm();
        },
      ),
      routes: {
        '/home': (context) => HomeForm(repos: repos,
            authBloc: authBloc),
        '/register': (context) => RegisterForm(repos: repos),
        '/login': (context) => LoginForm(repos: repos,
            authBloc: authBloc),
      },   
    );
  }
}
