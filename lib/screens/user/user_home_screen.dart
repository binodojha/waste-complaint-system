import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swms/components/waste_report_form.dart';
import 'package:swms/components/user_navigation_bar.dart';

class UserHomeScreen extends StatefulWidget {
  static String id = 'home_screen';
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

final _firestore = FirebaseFirestore.instance;
final loggedInUser = FirebaseAuth.instance.currentUser?.email!;

class _UserHomeScreenState extends State<UserHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: UserNavBar(),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Complaints",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 10),
          padding: EdgeInsets.all(10),
          width: double.infinity,
          height: 250,
          decoration: BoxDecoration(
            color: Colors.blueGrey[100],
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: AllComplaints(),
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
              Text("Report a Waste Pickup"),
            ],
          ),
        ),
      ],
    );
  }
}

class AllComplaints extends StatelessWidget {
  AllComplaints({super.key});

  BoxDecoration? statusDecoration;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('complaints')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          List<Container> complaintWidgets = [];
          if (snapshot.hasData) {
            final complaints = snapshot.data?.docs;
            for (var complaint in complaints!) {
              if (complaint['status'] == 'pending') {
                statusDecoration = BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4.0),
                );
              } else if (complaint['status'] == 'In Progress') {
                statusDecoration = BoxDecoration(
                  color: Colors.amber[700],
                  borderRadius: BorderRadius.circular(4.0),
                );
              } else if (complaint['status'] == 'Rejected') {
                statusDecoration = BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(4.0),
                );
              } else {
                statusDecoration = BoxDecoration(
                  // color: Color.fromARGB(1000, 5, 150, 105),
                  color: Colors.green[700],
                  borderRadius: BorderRadius.circular(4.0),
                );
              }
              if (loggedInUser == complaint['email']) {
                final complaintWidget = Container(
                  margin: EdgeInsets.only(top: 10),
                  padding: EdgeInsets.all(10),
                  height: 60,
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Text(
                          complaint['title'],
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Image.memory(
                          base64Decode(complaint['image']),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          complaint['location'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Container(
                          padding: EdgeInsets.all(5),
                          decoration: statusDecoration,
                          child: Text(
                            complaint['status'],
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
                complaintWidgets.add(complaintWidget);
              }
            }
          }
          if (complaintWidgets.isEmpty) {
            return Container(
              child: Center(
                child: Text(
                  "No complaints Yet!",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Colors.black,
                  ),
                ),
              ),
            );
          }
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: complaintWidgets,
            ),
          );
        });
  }
}
