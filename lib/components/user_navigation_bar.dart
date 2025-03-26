import 'package:flutter/material.dart';
import 'package:swms/screens/user/user_all_reports_screen.dart';

import 'package:swms/screens/user/user_home_screen.dart';
import 'package:swms/screens/user/user_profile_screen.dart';

class UserNavBar extends StatelessWidget {
  final int currentIndex;
  const UserNavBar({super.key, this.currentIndex = 0});
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.blueGrey,
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      iconSize: 22,
      onTap: (index) {
        if (index == 0 && currentIndex != 0) {
          Navigator.pushReplacementNamed(context, UserHomeScreen.id);
          // } else if (index == 1 && currentIndex != 1) {
          //   Navigator.pushReplacementNamed(context, AdminComplaintScreen.id);
        } else if (index == 2 && currentIndex != 2) {
          Navigator.pushReplacementNamed(context, UserReports.id);
        } else if (index == 3 && currentIndex != 3) {
          Navigator.pushReplacementNamed(context, UserProfileScreen.id);
        }
      },
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
