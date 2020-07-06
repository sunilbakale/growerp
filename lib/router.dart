import 'package:flutter/material.dart';
import 'routing_constants.dart';
import 'forms/@forms.dart';

// https://medium.com/flutter-community/flutter-navigation-cheatsheet-a-guide-to-named-routing-dc642702b98c
Route<dynamic> generateRoute(RouteSettings settings) {
  print("Navigate to ${settings.name}");
  switch (settings.name) {
    case HomeRoute:
      final String message = settings.arguments;
      return MaterialPageRoute(
          builder: (context) => HomeForm(message: message));
    case ProductRoute:
      return MaterialPageRoute(
          builder: (context) => ProductForm(product: settings.arguments));
    case LoginRoute:
      final String message = settings.arguments;
      return MaterialPageRoute(
          builder: (context) => LoginForm(message: message));
    case RegisterRoute:
      return MaterialPageRoute(builder: (context) => RegisterForm());
    case ChangePwRoute:
      ChangePwArgs changePwArgs = settings.arguments;
      return MaterialPageRoute(
          builder: (context) => ChangePwForm(changePwArgs: changePwArgs));
    case CartRoute:
      return MaterialPageRoute(builder: (context) => CartForm());
    default:
      return MaterialPageRoute(
          builder: (context) => UndefinedView(name: settings.name));
  }
}
