import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      iconSize: 22,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: "Alerts",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.report),
          label: "Report",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_4_sharp),
          label: "Profile",
        ),
      ],
    );
  }
}
