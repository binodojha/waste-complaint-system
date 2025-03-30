import 'package:flutter/material.dart';
import 'package:swms/screens/admin/admin_screen.dart';
import 'package:swms/screens/admin/admin_complaint_screen.dart';
import 'package:swms/screens/admin/user_manage_screen.dart';
import 'package:swms/screens/admin/admin_profile_screen.dart';
import 'package:swms/screens/user/user_home_screen.dart';

class AdminNavBar extends StatelessWidget {
  final int currentIndex;
  const AdminNavBar({super.key, this.currentIndex = 0});
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.blueGrey,
      type: BottomNavigationBarType.fixed,
      iconSize: 22,
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == 0 && currentIndex != 0) {
          Navigator.pushReplacementNamed(context, AdminScreen.id);
        } else if (index == 1 && currentIndex != 1) {
          Navigator.pushReplacementNamed(context, AdminComplaintScreen.id);
        } else if (index == 2 && currentIndex != 2) {
          Navigator.pushReplacementNamed(context, UserManageScreen.id);
        } else if (index == 3 && currentIndex != 3) {
          Navigator.pushReplacementNamed(context, AdminProfileScreen.id);
        }
      },
      items: const <BottomNavigationBarItem>[
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
