import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swms/components/waste_report_form.dart';
import 'package:swms/components/user_navigation_bar.dart';
import 'package:swms/screens/user/user_all_reports_screen.dart';

class UserHomeScreen extends StatefulWidget {
  static const String id = 'home_screen';
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
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Text(
            "Welcome Back!",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 28,
              color: Color.fromARGB(1000, 5, 150, 105),
            ),
          ),
          SizedBox(height: 20),

          // Statistics Section
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                  icon: Icons.pending_actions,
                  title: "Pending",
                  color: Colors.red,
                  stream: _firestore
                      .collection('complaints')
                      .where('email', isEqualTo: loggedInUser)
                      .where('status', isEqualTo: 'Pending')
                      .snapshots(),
                ),
                _buildStatItem(
                  icon: Icons.engineering,
                  title: "In Progress",
                  color: Colors.blueAccent,
                  stream: _firestore
                      .collection('complaints')
                      .where('email', isEqualTo: loggedInUser)
                      .where('status', isEqualTo: 'In Progress')
                      .snapshots(),
                ),
                _buildStatItem(
                  icon: Icons.check_circle,
                  title: "Completed",
                  color: Colors.green,
                  stream: _firestore
                      .collection('complaints')
                      .where('email', isEqualTo: loggedInUser)
                      .where('status', isEqualTo: 'Completed')
                      .snapshots(),
                ),
                _buildStatItem(
                  icon: Icons.cancel,
                  title: "Rejected",
                  color: Colors.black,
                  stream: _firestore
                      .collection('complaints')
                      .where('email', isEqualTo: loggedInUser)
                      .where('status', isEqualTo: 'Rejected')
                      .snapshots(),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Quick Actions
          Text(
            "Quick Actions",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  context,
                  icon: Icons.add_circle,
                  title: "New Complaint",
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ReportForm();
                      },
                    );
                  },
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildQuickActionButton(
                  context,
                  icon: Icons.history,
                  title: "History",
                  onTap: () {
                    Navigator.pushNamed(context, UserReports.id);
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Recent Complaints Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recent Complaints",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
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
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required Color color,
    required Stream stream,
  }) {
    return StreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return Column(
          children: [
            Icon(icon, color: color, size: 30),
            SizedBox(height: 5),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Color.fromARGB(1000, 5, 150, 105), size: 30),
            SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AllComplaints extends StatefulWidget {
  const AllComplaints({super.key});

  @override
  State<AllComplaints> createState() => _AllComplaintsState();
}

class _AllComplaintsState extends State<AllComplaints> {
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
              if (complaint['status'] == 'Pending') {
                statusDecoration = BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4.0),
                );
              } else if (complaint['status'] == 'In Progress') {
                statusDecoration = BoxDecoration(
                  color: Colors.amber[700],
                  borderRadius: BorderRadius.circular(4.0),
                );
              } else if (complaint['status'] == 'Accepted') {
                statusDecoration = BoxDecoration(
                  color: Colors.lightGreen,
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
                if (complaint['status'] != 'Completed' &&
                    complaint['status'] != "Rejected") {
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
