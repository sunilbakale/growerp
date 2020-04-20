import 'package:flutter/material.dart';
import 'package:growerp/styles/themes.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'services/user_repository.dart';

import 'bloc/authentication/authentication.dart';
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
  final userRepository = UserRepository();
  final authenticationBloc = AuthenticationBloc(userRepository: userRepository);

  runApp(
    BlocProvider<AuthenticationBloc>(
      create: (context) {
        return AuthenticationBloc(userRepository: userRepository)
          ..add(AppStarted());
      },
      child: App(userRepository: userRepository,
          authenticationBloc: authenticationBloc),
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
  final UserRepository userRepository;
  final AuthenticationBloc authenticationBloc;

  App({Key key, @required this.userRepository,
                     @required this.authenticationBloc})
    : assert(userRepository != null, authenticationBloc != null),
    super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Themes.formTheme,
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          print("====main.dart=====state: $state");
          if (state is AuthenticationConnectionProblem) {
            return NoConnectionForm();
          } else if (state is AuthenticationAuthenticated) {
            print("==main.dart: yes autenticated, go to home form");
            return HomeForm(userRepository: userRepository,
              authenticationBloc: authenticationBloc);
          } else if (state is AuthenticationUnauthenticated) {
            print("==main.dart: no, not autenticated, go to login form");
            return LoginForm(userRepository: userRepository,
              authenticationBloc: authenticationBloc);
          } else if (state is AuthenticationLoading) {
            return LoadingIndicator();
          } else if (state is AuthenticationRegister) {
            return RegisterForm(userRepository: userRepository);
          } else return SplashForm();
        },
      ),
      routes: {
        '/home': (context) => HomeForm(userRepository: userRepository,
            authenticationBloc: authenticationBloc),
        '/register': (context) => RegisterForm(userRepository: userRepository),
        '/login': (context) => LoginForm(userRepository: userRepository,
            authenticationBloc: authenticationBloc),
      },   
    );
  }
}
