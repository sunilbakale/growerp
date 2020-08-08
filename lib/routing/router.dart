import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../routing/route_names.dart';
import '../forms/@forms.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case HomeRoute:
      return _getPageRoute(HomeForm(), settings.name);
    case AboutRoute:
      return _getPageRoute(AboutForm(), settings.name);
    case OfbizRoute:
      return _getPageRoute(OfbizForm(), settings.name);
    case MoquiRoute:
      return _getPageRoute(MoquiForm(), settings.name);
    default:
      return null;
  }
}

PageRoute _getPageRoute(Widget child, String routeName) {
  return _FadeRoute(child: child, routeName: routeName);
}

class _FadeRoute extends PageRouteBuilder {
  final Widget child;
  final String routeName;
  _FadeRoute({this.child, this.routeName})
      : super(
            pageBuilder: (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) =>
                child,
            settings: RouteSettings(name: routeName),
            transitionsBuilder: (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child,
            ) =>
                FadeTransition(
                  opacity: animation,
                  child: child,
                ));
}
