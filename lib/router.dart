import 'package:flutter/material.dart';
import 'routing_constants.dart';
import 'forms/@forms.dart';

// https://medium.com/flutter-community/flutter-navigation-cheatsheet-a-guide-to-named-routing-dc642702b98c
Route<dynamic> generateRoute(RouteSettings settings) {
  print(
      ">>> Navigate to ${settings.name} with data: ${settings.arguments.toString()}");
  switch (settings.name) {
    case HomeRoute:
      return MaterialPageRoute(
          builder: (context) => HomeForm(message: settings.arguments));
    case ProductRoute:
      return MaterialPageRoute(
          builder: (context) => ProductForm(product: settings.arguments));
    case LoginRoute:
      return MaterialPageRoute(builder: (context) => LoginForm());
    case RegisterRoute:
      return MaterialPageRoute(builder: (context) => RegisterForm());
    case ChangePwRoute:
      return MaterialPageRoute(
          builder: (context) => ChangePwForm(changePwArgs: settings.arguments));
    case CartRoute:
      return MaterialPageRoute(builder: (context) => CartForm());
    default:
      return MaterialPageRoute(
          builder: (context) => UndefinedView(name: settings.name));
  }
}
