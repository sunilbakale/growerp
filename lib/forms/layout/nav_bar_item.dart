import 'package:flutter/material.dart';
import '../../services/navigation_service.dart';
import '../../locator.dart';

class NavBarItem extends StatelessWidget {
  final bool drawer;
  final String title;
  final String navigationPath;
  const NavBarItem(this.title, this.navigationPath, [this.drawer = false]);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // DON'T EVER USE A SERVICE DIRECTLY IN THE UI TO CHANGE ANY KIND OF STATE
        // SERVICES SHOULD ONLY BE USED FROM A VIEWMODEL
        if (drawer) Navigator.pop(context);
        locator<NavigationService>().navigateTo(navigationPath);
      },
      child: Text(
        title,
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}
