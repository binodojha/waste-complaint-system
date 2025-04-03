import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swms/components/user_navigation_bar.dart';

class UserReports extends StatefulWidget {
  static const String id = "user_all_reports";
  const UserReports({super.key});
  @override
  State<StatefulWidget> createState() => _AllUserReports();
}

final _firestore = FirebaseFirestore.instance;
final loggedInUser = FirebaseAuth.instance.currentUser?.email!;

class _AllUserReports extends State<UserReports> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: UserNavBar(
        currentIndex: 2,
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 100,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          margin: EdgeInsets.only(top: 30, left: 15, right: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  'Report History',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(1000, 5, 150, 105),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              _buildSectionHeader(
                'Completed Reports',
                Icons.check_circle,
                Colors.green,
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: AllComplaints(
                  status: 'Completed',
                ),
              ),
              SizedBox(
                height: 50,
              ),
              _buildSectionHeader(
                'Rejected Reports',
                Icons.cancel,
                Colors.black,
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: AllComplaints(
                  status: 'Rejected',
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildSectionHeader(String title, IconData icon, Color color) {
  return Row(
    children: [
      Icon(icon, color: color, size: 24),
      SizedBox(width: 10),
      Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}

class AllComplaints extends StatefulWidget {
  const AllComplaints({super.key, this.status});
  final String? status;

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
              if (complaint['status'] == 'Rejected') {
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
                if (complaint['status'] == widget.status) {
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
              margin: EdgeInsets.only(top: 10),
              child: Center(
                child: Text(
                  "No ${widget.status} complaints Yet!",
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
