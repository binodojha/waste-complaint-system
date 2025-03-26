import 'package:flutter/material.dart';
import 'package:swms/components/admin_complaint_card.dart';
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
        child: Expanded(
          child: StreamBuilder(
            stream: _firebaseService.getComplaints(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              var complaints = snapshot.data!;
              return ListView.builder(
                itemCount: complaints.length,
                itemBuilder: (context, index) {
                  return complaints[index]['status'] != "Completed" &&
                          complaints[index]['status'] != "Rejected"
                      ? ExpandableComplaintCard(
                          id: complaints[index]['id'],
                          title: complaints[index]['title'],
                          description: complaints[index]['description'],
                          location: complaints[index]['location'],
                          status: complaints[index]['status'],
                          image: complaints[index]['image'],
                          onTap: () => toggleExpansion(index),
                          isExpanded: expandedIndex == index,
                          status1: "Rejected",
                          status2: "Completed",
                        )
                      : Container();
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
