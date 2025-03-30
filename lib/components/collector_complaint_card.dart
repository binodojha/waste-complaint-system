import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swms/utils/firebase_serivce.dart';

final FirebaseSerivce _firebaseService = FirebaseSerivce();
final String? currentUserEmail = FirebaseAuth.instance.currentUser?.email;

class CollectorExpandableComplaintCard extends StatefulWidget {
  final String title;
  final String description;
  final String location;
  final String status;
  final String image;
  final bool isExpanded;
  final VoidCallback onTap;
  final String status1, status2;
  final id;
  final String collectorEmail;

  const CollectorExpandableComplaintCard(
      {super.key,
      required this.title,
      required this.description,
      required this.image,
      required this.location,
      required this.status,
      required this.onTap,
      required this.isExpanded,
      required this.id,
      required this.status1,
      required this.collectorEmail,
      required this.status2});

  @override
  State<CollectorExpandableComplaintCard> createState() =>
      _ExpandableComplaintCardState();
}

class _ExpandableComplaintCardState
    extends State<CollectorExpandableComplaintCard> {
  //Track the new status
  String? updatedStatus;
  void updatStatus(BuildContext context, String docId, String newStatus,
      collectorEmail) async {
    try {
      await _firebaseService.updateComplaintStatus(
          docId, newStatus, collectorEmail);
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
        margin:
            widget.status == widget.status1 || widget.status == widget.status2
                ? EdgeInsets.only(bottom: 15)
                : EdgeInsets.all(0),
        padding:
            widget.status == widget.status1 || widget.status == widget.status2
                ? EdgeInsets.only(left: 10, right: 20, bottom: 5, top: 5)
                : EdgeInsets.all(0),
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
            if (widget.status == widget.status1 ||
                widget.status == widget.status2)
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (widget.status == widget.status1 ||
                widget.status == widget.status2)
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
                          color: displayStatus == 'Pending'
                              ? Colors.red
                              : displayStatus == 'Approved'
                                  ? const Color.fromARGB(255, 70, 170, 185)
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          displayStatus == 'Approved'
                              ? actionButton(
                                  title: 'Accept',
                                  icon: Icons.check,
                                  onClicked: () => updatStatus(
                                      context,
                                      widget.id,
                                      'In Progress',
                                      currentUserEmail),
                                )
                              : Container(),
                        ],
                      ),
                      if (displayStatus == 'In Progress')
                        Row(
                          children: [
                            displayStatus == 'In Progress' &&
                                    widget.collectorEmail == currentUserEmail
                                ? actionButton(
                                    title: 'Completed',
                                    icon: Icons.check,
                                    onClicked: () => updatStatus(
                                        context,
                                        widget.id,
                                        'Completed',
                                        currentUserEmail),
                                  )
                                : Container(),
                          ],
                        ),
                    ],
                  )
              ],
          ],
        ),
      ),
    );
  }
}

Widget actionButton({
  required String title,
  required IconData icon,
  required VoidCallback onClicked,
}) {
  return ElevatedButton(
    onPressed: onClicked,
    style: ElevatedButton.styleFrom(
      backgroundColor: title == "Accept"
          ? Color.fromARGB(1000, 5, 150, 105)
          : title == "Completed"
              ? const Color.fromARGB(255, 39, 116, 41)
              : Colors.red,
      shape: LinearBorder(),
    ),
    child: Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        SizedBox(
          width: 10,
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
