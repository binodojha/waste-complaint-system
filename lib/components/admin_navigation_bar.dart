import 'package:flutter/material.dart';

class AdminNavBar extends StatelessWidget {
  const AdminNavBar({super.key});
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
          icon: Icon(Icons.report_problem),
          label: "Complaints",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.supervised_user_circle),
          label: "Users",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_4_sharp),
          label: "Profile",
        ),
      ],
    );
  }
}
