import 'package:flutter/material.dart';
import 'package:swms/components/admin_complaint_card.dart';
import 'package:swms/components/admin_navigation_bar.dart';
import 'package:swms/utils/firebase_serivce.dart';

class AdminComplaintScreen extends StatefulWidget {
  static String id = 'complaint_screen';
  const AdminComplaintScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<AdminComplaintScreen> {
  int? expandedIndex;
  void toggleExpansion(int index) {
    setState(() {
      if (expandedIndex == index) {
        expandedIndex = null; // Collapse if already expanded
      } else {
        expandedIndex = index; // Expand the new one
      }
    });
  }

  final FirebaseSerivce _firebaseService = FirebaseSerivce();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: AdminNavBar(
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
            // CircleAvatar(
            //     // backgroundImage: AssetImage(''),
            //     ),
          ],
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(left: 20, right: 20, top: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Completed Reports",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(1000, 5, 150, 105),
              ),
            ),
            SizedBox(
              height: 15,
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
                      .where((c) => c['status'] != 'Completed')
                      .toList();

                  // If there are no complaints with "Completed" status, show message
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
                      return complaints[index]['status'] == "Completed"
                          ? ExpandableComplaintCard(
                              id: complaints[index]['id'],
                              title: complaints[index]['title'],
                              description: complaints[index]['description'],
                              location: complaints[index]['location'],
                              status: complaints[index]['status'],
                              image: complaints[index]['image'],
                              onTap: () => toggleExpansion(index),
                              isExpanded: expandedIndex == index,
                              status1: "Pending",
                              status2: "Approved",
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
