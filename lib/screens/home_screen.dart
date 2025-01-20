import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swms/components/waste_report_form.dart';

class UserHomeScreen extends StatelessWidget {
  static String id = 'home_screen';
  UserHomeScreen({super.key});
  final _auth = FirebaseAuth.instance;

  void getCurrentUser() async {
    final user = await _auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 100,
            ),
            // CircleAvatar(
            //     // backgroundImage: AssetImage(''),
            //     ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(),
        margin: EdgeInsets.only(left: 20, right: 20, top: 30),
        child: UserHome(),
      ),
    );
  }
}

// User Main Body

class UserHome extends StatelessWidget {
  const UserHome({super.key});

  @override
  Widget build(BuildContext context) {
    return (Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Upcoming Pickups",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 10),
          padding: EdgeInsets.all(10),
          width: double.infinity,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Text(""),
        ),
        SizedBox(
          height: 30,
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            iconSize: 22,
            textStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            padding: EdgeInsets.all(15),
            shape:
                BeveledRectangleBorder(borderRadius: BorderRadius.circular(4)),
            iconColor: Colors.white,
            foregroundColor: Colors.white,
            backgroundColor: Color.fromARGB(1000, 5, 150, 105),
          ),
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return ReportForm();
                });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
              ),
              SizedBox(
                width: 10,
              ),
              Text("Report Missed PickUp"),
            ],
          ),
        ),
      ],
    ));
  }
}

// Bottom Navigation Bar
class NavigationBar extends StatelessWidget {
  const NavigationBar({super.key});
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
