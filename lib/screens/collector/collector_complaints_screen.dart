import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swms/components/collector_complaint_card.dart';
import 'package:swms/components/collector_navigation_bar.dart';
import 'package:swms/utils/firebase_serivce.dart';

class CollectorComplaintScreen extends StatefulWidget {
  static const String id = 'collector_complaints_screen';
  const CollectorComplaintScreen({super.key});
  @override
  State<StatefulWidget> createState() => _CollectorComplaintScreen();
}

final FirebaseSerivce _firebaseService = FirebaseSerivce();
String? currentUserEmail;

class _CollectorComplaintScreen extends State<CollectorComplaintScreen> {
  int? expandedIndex;
  @override
  void initState() {
    currentUserEmail = FirebaseAuth.instance.currentUser!.email;
    super.initState();
  }

  void toggleExpansion(int index) {
    setState(() {
      if (expandedIndex == index) {
        expandedIndex = null; // Collapse if already expanded
      } else {
        expandedIndex = index; // Expand the new one
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CollectorNavBar(
        currentIndex: 1,
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
      body: Container(
        margin: EdgeInsets.only(top: 20, left: 15, right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Completed Complaints",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: StreamBuilder(
                stream: _firebaseService.getComplaints(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  var complaints = snapshot.data!;
                  final completedComplaints = complaints
                      .where((c) =>
                          c['status'] != 'Completed' &&
                          c['collectorEmail'] == currentUserEmail)
                      .toList();
                  if (completedComplaints.isEmpty) {
                    return Center(
                      child: Text(
                        "No complaints available",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: complaints.length,
                    itemBuilder: (context, index) {
                      return complaints[index]['status'] == "Completed" &&
                              complaints[index]['collectorEmail'] ==
                                  currentUserEmail
                          ? CollectorExpandableComplaintCard(
                              id: complaints[index]['id'],
                              title: complaints[index]['title'],
                              description: complaints[index]['description'],
                              location: complaints[index]['location'],
                              status: complaints[index]['status'],
                              image: complaints[index]['image'],
                              collectorEmail: complaints[index]
                                  ['collectorEmail'],
                              onTap: () => toggleExpansion(index),
                              isExpanded: expandedIndex == index,
                              status1: "",
                              status2: "Completed",
                            )
                          : Container();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
