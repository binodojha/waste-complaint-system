import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:swms/components/admin_navigation_bar.dart';

class AdminScreen extends StatefulWidget {
  static String id = 'admin_screen';
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
        decoration: BoxDecoration(),
        margin: EdgeInsets.only(left: 20, right: 20, top: 30),
        child: StreamBuilder(
          stream: _firestore.collection('complaints').snapshots(),
          builder: (context, snapshot) {
            var complaints = snapshot.data!.docs.map((doc) {
              return {
                'id': doc.id,
                'title': doc['title'],
                'description': doc['description'],
                'location': doc['location'],
                'email': doc['email'],
                'image': doc['image'],
                'timestamp': doc['timestamp'],
                'status': doc['status'],
              };
            }).toList();
            return ListView.builder(
              itemCount: complaints.length,
              itemBuilder: (context, index) {
                return ExpandableComplaintCard(
                  id: complaints[index]['id'],
                  title: complaints[index]['title'],
                  description: complaints[index]['description'],
                  location: complaints[index]['location'],
                  status: complaints[index]['status'],
                  image: complaints[index]['image'],
                  onTap: () => toggleExpansion(index),
                  isExpanded: expandedIndex == index,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class ExpandableComplaintCard extends StatefulWidget {
  final String title;
  final String description;
  final String location;
  final String status;
  final String image;
  final bool isExpanded;
  final VoidCallback onTap;
  final id;

  const ExpandableComplaintCard(
      {super.key,
      required this.title,
      required this.description,
      required this.image,
      required this.location,
      required this.status,
      required this.onTap,
      required this.isExpanded,
      required this.id});

  @override
  State<ExpandableComplaintCard> createState() =>
      _ExpandableComplaintCardState();
}

class _ExpandableComplaintCardState extends State<ExpandableComplaintCard> {
  //Track the new status
  String? updatedStatus;
  void updatStatus(BuildContext context, String docId, String newStatus) async {
    try {
      await _firestore.collection('complaints').doc(docId).update({
        'status': newStatus,
        'timestamp': FieldValue.serverTimestamp(),
      });
      setState(() {
        updatedStatus = newStatus;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Status updated successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error while updating")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine which status to show (updated or original)
    String displayStatus = updatedStatus ?? widget.status;
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.only(left: 10, right: 20, bottom: 5, top: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 4),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.isExpanded) ...[
              SizedBox(
                height: 10,
              ),
              Text("Description: ${widget.description}"),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                width: double.maxFinite,
                height: 200,
                child: Image.memory(
                  fit: BoxFit.fill,
                  base64Decode(widget.image),
                ),
              ),
              Text("Location: ${widget.location}"),
              Row(
                children: [
                  Text("Status: "),
                  Text(
                    displayStatus,
                    style: TextStyle(
                        color: displayStatus == 'pending'
                            ? Colors.red
                            : displayStatus == 'In Progress'
                                ? Colors.amber[700]
                                : displayStatus == 'Rejected'
                                    ? Colors.black
                                    : Colors.green,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (updatedStatus == null)
                Row(
                  children: [
                    displayStatus == 'pending'
                        ? ActionButton(
                            title: 'Accept',
                            icon: Icons.check,
                            onClicked: () =>
                                updatStatus(context, widget.id, 'In Progress'),
                          )
                        : Container(),
                    SizedBox(
                      width: 20,
                    ),
                    displayStatus == 'pending'
                        ? ActionButton(
                            title: 'Reject',
                            icon: Icons.close,
                            onClicked: () =>
                                updatStatus(context, widget.id, 'Rejected'),
                          )
                        : Container(),
                  ],
                )
            ],
          ],
        ),
      ),
    );
  }
}

Widget ActionButton({
  required String title,
  required IconData icon,
  required VoidCallback onClicked,
}) {
  return ElevatedButton(
    onPressed: onClicked,
    style: ElevatedButton.styleFrom(
      backgroundColor:
          title == "Accept" ? Color.fromARGB(1000, 5, 150, 105) : Colors.red,
      shape: LinearBorder(),
    ),
    child: Row(
      spacing: 10.0,
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        Text(
          title,
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ],
    ),
  );
}
