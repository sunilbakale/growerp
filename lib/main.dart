import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'forms/forms.dart';
import 'bloc/bloc.dart';
import 'services/repos.dart';

void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  final repos = Repos();
  runApp(MyApp(repos: repos));
}

class MyApp extends StatelessWidget {
  final Repos repos;

  MyApp({Key key, @required this.repos})
      : assert(repos != null),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CatalogBloc>(
          create: (context) => CatalogBloc(repos: repos)..add(LoadCatalog()),
        ),
        BlocProvider<CartBloc>(
          create: (context) => CartBloc()..add(LoadCart()),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Bloc Shopping Cart',
        routes: {
          '/': (context) => HomeForm(repos: repos),
          '/details': (context) => ProductDetailsForm(),
          '/cart': (context) => CartForm(),
        },
      ),
    );
  }
}

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onEvent(Bloc bloc, Object event) {
    print('${bloc.runtimeType} $event');
    super.onEvent(bloc, event);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stackTrace) {
    print('${bloc.runtimeType} $error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    print(transition);
    super.onTransition(bloc, transition);
  }
}
