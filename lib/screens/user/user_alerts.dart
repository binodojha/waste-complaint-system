import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swms/components/user_navigation_bar.dart';
import 'dart:async';

class UserAlerts extends StatefulWidget {
  static const String id = 'user_alerts_screen';
  const UserAlerts({super.key});

  @override
  State<UserAlerts> createState() => _UserAlertsState();
}

class _UserAlertsState extends State<UserAlerts> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  String? loggedInUser;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    loggedInUser = _auth.currentUser?.email;
    _refreshTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  String _getStatusIcon(String status) {
    switch (status) {
      case 'In Progress':
        return '🔧';
      case 'Completed':
        return '✅';
      case 'Pending':
        return '⌛';
      case 'Rejected':
        return '❌';
      default:
        return '📝';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'In Progress':
        return Colors.blue;
      case 'Completed':
        return const Color.fromARGB(255, 160, 224, 162);
      case 'Rejected':
        return const Color.fromARGB(255, 223, 142, 136);
      default:
        return const Color.fromARGB(255, 46, 46, 46);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: UserNavBar(currentIndex: 1),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'Notifications',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(1000, 5, 150, 105),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('complaints')
                  .where('email', isEqualTo: loggedInUser)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Error loading notifications',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color.fromARGB(1000, 5, 150, 105),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Loading notifications...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No notifications yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Your complaint notifications will appear here',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final sortedDocs = snapshot.data!.docs.toList()
                  ..sort((a, b) {
                    final aTimestamp = a['timestamp'] as Timestamp;
                    final bTimestamp = b['timestamp'] as Timestamp;
                    return bTimestamp.compareTo(aTimestamp);
                  })
                  ..removeWhere((doc) {
                    final status = doc['status'];
                    final timestamp = doc['timestamp'] as Timestamp;
                    final now = DateTime.now();
                    final difference = now.difference(timestamp.toDate());

                    if ((status == 'Completed' || status == 'Rejected') &&
                        difference.inMinutes >= 5) {
                      return true;
                    }
                    return false;
                  });

                if (sortedDocs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No active notifications',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: sortedDocs.length,
                  itemBuilder: (context, index) {
                    final complaint = sortedDocs[index];
                    final status = complaint['status'];
                    final title = complaint['title'];
                    final timestamp = complaint['timestamp'] as Timestamp;
                    final date = timestamp.toDate();

                    // Add remaining time indicator for completed/rejected complaints
                    String? remainingTime;
                    if (status == 'Completed' || status == 'Rejected') {
                      final now = DateTime.now();
                      final difference = now.difference(date);
                      final remainingMinutes = 5 - difference.inMinutes;
                      if (remainingMinutes > 0) {
                        remainingTime =
                            'Disappearing in $remainingMinutes minute${remainingMinutes == 1 ? '' : 's'}';
                      }
                    }
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 2,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(status),
                          child: Text(
                            _getStatusIcon(status),
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text('Title: $title'),
                            Text(
                              'Status: $status',
                              style: TextStyle(
                                color: _getStatusColor(status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Updated: ${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            if (remainingTime != null)
                              Text(
                                remainingTime,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                        isThreeLine: true,
                        onTap: () {
                          // Show more details if needed
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Complaint Details'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Title: ${complaint['title']}'),
                                  SizedBox(height: 8),
                                  Text(
                                      'Description: ${complaint['description']}'),
                                  SizedBox(height: 8),
                                  Text('Location: ${complaint['location']}'),
                                  SizedBox(height: 8),
                                  Text(
                                    'Status: ${complaint['status']}',
                                    style: TextStyle(
                                      color:
                                          _getStatusColor(complaint['status']),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (complaint['collectorEmail'] != null &&
                                      complaint['collectorEmail'].isNotEmpty)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 8),
                                        Text(
                                            'Assigned to: ${complaint['collectorEmail']}'),
                                      ],
                                    ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
