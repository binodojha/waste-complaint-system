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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          var complaints = snapshot.data!;
          // Count the complaints
          String totalComplaintsInt = complaints.length.toString();
          String pendingComplaintsInt = complaints
              .where((c) => c['status'] == 'Pending')
              .length
              .toString();
          String completedComplaintsInt = complaints
              .where((c) => c['status'] == 'Completed')
              .length
              .toString();
          String inProgressComplaintsInt = complaints
              .where((c) => c['status'] == 'In Progress')
              .length
              .toString();
          String approvedComplaintsInt = complaints
              .where((c) => c['status'] == 'Approved')
              .length
              .toString();
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                complaintNumberWidget(
                    statusTitle: 'Total Complaints',
                    numberTitle: totalComplaintsInt,
                    color: Color.fromARGB(1000, 5, 150, 105),
                    statusTitleSize: 15.0,
                    numberTitleSize: 20.0),
                SizedBox(
                  width: 12,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        complaintNumberWidget(
                          statusTitle: 'Pending',
                          numberTitle: pendingComplaintsInt,
                          color: Colors.amber[500],
                          statusTitleSize: 15.0,
                          numberTitleSize: 20.0,
                          width: 92.0,
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        complaintNumberWidget(
                          statusTitle: 'Approved',
                          numberTitle: approvedComplaintsInt,
                          color: Colors.blueAccent,
                          statusTitleSize: 15.0,
                          numberTitleSize: 20.0,
                          width: 92.0,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        complaintNumberWidget(
                          statusTitle: 'In Progress',
                          numberTitle: inProgressComplaintsInt,
                          color: Colors.green,
                          statusTitleSize: 15.0,
                          numberTitleSize: 20.0,
                          width: 92.0,
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        complaintNumberWidget(
                          statusTitle: 'Completed',
                          numberTitle: completedComplaintsInt,
                          color: Colors.lightGreen,
                          statusTitleSize: 15.0,
                          numberTitleSize: 20.0,
                          width: 92.0,
                        ),
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

Widget complaintNumberWidget({
  required String statusTitle,
  required String numberTitle,
  required color,
  required statusTitleSize,
  required numberTitleSize,
  width,
  height,
}) {
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
          statusTitle,
          style: commonTextStyle.copyWith(
            fontSize: statusTitleSize,
          ),
        ),
        Text(
          numberTitle,
          style: commonTextStyle.copyWith(
            fontSize: numberTitleSize,
          ),
        ),
      ],
    ),
  );
}
