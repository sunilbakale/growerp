import 'package:flutter/material.dart';
import 'forms/forms.dart';
import 'services/repos.dart';


void main() {
  final repos = Repos();
  runApp(
    App(repos: repos));
}

class App extends StatelessWidget {
  final Repos repos;

  App({Key key, @required this.repos})
    : assert(repos != null), 
      super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeForm(repos: repos),
    );
  }
}



