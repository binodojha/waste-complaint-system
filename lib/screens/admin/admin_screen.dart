import 'package:flutter/material.dart';
import 'package:swms/utils/firebase_serivce.dart';
import 'package:swms/components/admin_navigation_bar.dart';
import 'package:swms/components/admin_complaint_card.dart';

class AdminScreen extends StatefulWidget {
  static String id = 'admin_screen';
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

final FirebaseSerivce _firebaseService = FirebaseSerivce();

class _AdminScreenState extends State<AdminScreen> {
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
      bottomNavigationBar: AdminNavBar(),
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
              "Dashboard",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              height: 150,
              width: double.maxFinite,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ComplaintsDashboard(),
            ),
            SizedBox(
              height: 40,
            ),
            Text(
              "Complaints",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
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
                      .where((c) =>
                          c['status'] != 'Completed' &&
                          c['status'] != 'Rejected')
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
                              complaints[index]['status'] != "Rejected"
                          ? ExpandableComplaintCard(
                              id: complaints[index]['id'] ?? 'Not Available',
                              title:
                                  complaints[index]['title'] ?? 'Not Available',
                              description: complaints[index]['description'] ??
                                  'Not Available',
                              location: complaints[index]['location'] ??
                                  'Not Available',
                              status: complaints[index]['status'] ??
                                  'Not Available',
                              image:
                                  complaints[index]['image'] ?? 'Not Available',
                              userEmail:
                                  complaints[index]['email'] ?? 'Not Available',
                              userContact: complaints[index]['contact'] ??
                                  'Not Available',
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
          ],
        ),
      ),
    );
  }
}

class ComplaintsDashboard extends StatelessWidget {
  const ComplaintsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _firebaseService.getComplaints(),
        builder: (context, snapshot) {
          var complaints = snapshot.data ?? [];
          // Count the complaints
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatItem(
                  title: 'Total Complaints',
                  complaints: complaints,
                  countFunction: (complaints) => complaints.length.toString(),
                  color: Color.fromARGB(1000, 5, 150, 105),
                ),
                SizedBox(
                  width: 12,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildStatItem(
                          title: 'Pending',
                          complaints: complaints,
                          countFunction: (complaints) => complaints
                              .where((c) => c['status'] == 'Pending')
                              .length
                              .toString(),
                          color: Colors.amber[500],
                          width: 92.0,
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        _buildStatItem(
                          title: 'Approved',
                          complaints: complaints,
                          countFunction: (complaints) => complaints
                              .where((c) => c['status'] == 'Approved')
                              .length
                              .toString(),
                          color: Colors.blueAccent,
                          width: 92.0,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _buildStatItem(
                          title: 'In Progress',
                          complaints: complaints,
                          countFunction: (complaints) => complaints
                              .where((c) => c['status'] == 'In Progress')
                              .length
                              .toString(),
                          color: Colors.green,
                          width: 92.0,
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        _buildStatItem(
                          title: 'Completed',
                          complaints: complaints,
                          countFunction: (complaints) => complaints
                              .where((c) => c['status'] == 'Completed')
                              .length
                              .toString(),
                          color: Colors.lightGreen,
                          width: 92.0,
                        )
                      ],
                    )
                  ],
                )
              ],
            ),
          );
        });
  }
}

Widget _buildStatItem({
  required String title,
  required List complaints,
  required Function countFunction,
  required color,
  double? width,
  double? height,
}) {
  String count = countFunction(complaints);
  TextStyle commonTextStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  return Container(
    width: width,
    height: height,
    padding: EdgeInsets.symmetric(horizontal: 5),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: commonTextStyle.copyWith(
            fontSize: 15.0,
          ),
        ),
        Text(
          count,
          style: commonTextStyle.copyWith(
            fontSize: 20.0,
          ),
        ),
      ],
    ),
  );
}
