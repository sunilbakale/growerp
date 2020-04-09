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
    print(event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    print(error);
  }
}

void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  final userRepository = UserRepository();

  runApp(
    BlocProvider<AuthenticationBloc>(
      create: (context) {
        if(!userRepository.connected()) {
          AuthenticationBloc(userRepository: userRepository)
          ..add(ConnectionProblem());
          }
        return AuthenticationBloc(userRepository: userRepository)
          ..add(AppStarted());
      },
      child: App(userRepository: userRepository),
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

  App({Key key, @required this.userRepository}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Themes.formTheme,
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is AuthenticationAuthenticated) {
            return HomeForm();
          }
          if (state is AuthenticationUnauthenticated) {
            return LoginForm(userRepository: userRepository);
          }
          if (state is AuthenticationLoading) {
            return LoadingIndicator();
          }
          return SplashForm();
        },
      ),
      routes: {
        '/register': (context) => RegisterForm(userRepository: userRepository),
        '/login': (context) => LoginForm(userRepository: userRepository),
      },   
    );
  }
}
