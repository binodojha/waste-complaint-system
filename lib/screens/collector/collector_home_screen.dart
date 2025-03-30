import 'package:flutter/material.dart';
import 'package:swms/components/collector_complaint_card.dart';
import 'package:swms/components/collector_navigation_bar.dart';
import 'package:swms/utils/firebase_serivce.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CollectorHomeScreen extends StatefulWidget {
  static const String id = 'collector_home_screen';
  const CollectorHomeScreen({super.key});
  @override
  State<StatefulWidget> createState() => _CollectorHomeScreen();
}

final FirebaseSerivce _firebaseService = FirebaseSerivce();

class _CollectorHomeScreen extends State<CollectorHomeScreen> {
  int? expandedIndex;
  final String? collectorEmail = FirebaseAuth.instance.currentUser?.email;

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
        elevation: 0,
        backgroundColor: Colors.white,
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
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 5),
              child: Text(
                'Waste Collection Tasks',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(1000, 5, 150, 105),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Task Statistics
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    title: "Approved",
                    icon: Icons.approval,
                    color: Colors.blue,
                    status: "Approved",
                  ),
                  _buildStatItem(
                    title: "In Progress",
                    icon: Icons.engineering,
                    color: Colors.amber.shade700,
                    status: "In Progress",
                  ),
                  _buildStatItem(
                    title: "Completed",
                    icon: Icons.check_circle,
                    color: Colors.green,
                    status: "Completed",
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Active Complaints Section
            _buildSectionHeader(
              "Active Tasks",
              Icons.assignment,
              Color.fromARGB(1000, 5, 150, 105),
            ),
            SizedBox(height: 10),
            Expanded(
              child: StreamBuilder(
                stream: _firebaseService.getComplaints(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Color.fromARGB(1000, 5, 150, 105),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState("No active tasks found");
                  }

                  var complaints = snapshot.data!;
                  var collectorComplaints = complaints
                      .where((c) =>
                          (c['collectorEmail'] == collectorEmail ||
                              c['collectorEmail'] == '') &&
                          (c['status'] == "Approved" ||
                              c['status'] == "In Progress") &&
                          c['status'] != "Completed" &&
                          c['status'] != "Rejected")
                      .toList();

                  if (collectorComplaints.isEmpty) {
                    return _buildEmptyState("No active tasks assigned to you");
                  }

                  return ListView.builder(
                    itemCount: collectorComplaints.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: CollectorExpandableComplaintCard(
                          id: collectorComplaints[index]['id'],
                          title: collectorComplaints[index]['title'],
                          description: collectorComplaints[index]
                              ['description'],
                          location: collectorComplaints[index]['location'],
                          status: collectorComplaints[index]['status'],
                          image: collectorComplaints[index]['image'],
                          collectorEmail: collectorComplaints[index]
                              ['collectorEmail'],
                          onTap: () => toggleExpansion(index),
                          isExpanded: expandedIndex == index,
                          status1: "Approved",
                          status2: "In Progress",
                        ),
                      );
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

  Widget _buildStatItem({
    required String title,
    required IconData icon,
    required Color color,
    required String status,
  }) {
    return StreamBuilder(
      stream: _firebaseService.getComplaints(),
      builder: (context, snapshot) {
        int count = 0;
        if (snapshot.hasData) {
          count = snapshot.data!
              .where((c) =>
                  c['status'] == status &&
                  c['collectorEmail'] == collectorEmail)
              .length;
        }
        return Column(
          children: [
            Icon(icon, color: color, size: 30),
            SizedBox(height: 8),
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
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
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

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 50,
            color: Colors.grey[400],
          ),
          SizedBox(height: 15),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
