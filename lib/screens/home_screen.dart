import 'package:flutter/material.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 100,
            ),
            // Text(
            //   "Safaii Sathi",
            //   style: TextStyle(
            //     fontSize: 20,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
            CircleAvatar(
              backgroundImage: AssetImage(''),
            ),
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
          onPressed: () {},
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
