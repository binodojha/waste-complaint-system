import 'package:flutter/material.dart';
import 'package:swms/components/collector_complaint_card.dart';
import 'package:swms/components/collector_navigation_bar.dart';
import 'package:swms/utils/firebase_serivce.dart';

class CollectorHomeScreen extends StatefulWidget {
  static const String id = 'collector_home_screen';
  const CollectorHomeScreen({super.key});
  @override
  State<StatefulWidget> createState() => _CollectorHomeScreen();
}

final FirebaseSerivce _firebaseService = FirebaseSerivce();

class _CollectorHomeScreen extends State<CollectorHomeScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CollectorNavBar(
        currentIndex: 0,
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
                'Complaints',
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
                            c['status'] != 'Rejected' &&
                            c['status'] != 'Pending' &&
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
                        return complaints[index]['status'] != "Completed" &&
                                complaints[index]['status'] != "Rejected" &&
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
                                status1: "Approved",
                                status2: "In Progress",
                              )
                            : Container();
                      },
                    );
                  },
                ),
              ),
            ],
          )),
    );
  }
}
