import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ManageUserComponent extends StatefulWidget {
  const ManageUserComponent({super.key});

  @override
  State<ManageUserComponent> createState() => _ManageUserComponentState();
}

class _ManageUserComponentState extends State<ManageUserComponent> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  bool _isLoading = true;
  String _selectedFilter = "All";

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _selectedFilter = "All";
      _isLoading = true;
    });

    try {
      final snapshot = await _firestore.collection('users').get();
      final List<Map<String, dynamic>> loadedUsers = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        loadedUsers.add({
          'id': doc.id,
          'name': data['name'] ?? 'No Name',
          'email': data['email'] ?? 'No Email',
          'role': data['role'] ?? 'Unknown',
          'timestamp': data['timestamp'] ?? Timestamp.now(),
        });
      }

      loadedUsers.sort((a, b) {
        final Timestamp aTimestamp = a['timestamp'] as Timestamp;
        final Timestamp bTimestamp = b['timestamp'] as Timestamp;
        return bTimestamp.compareTo(aTimestamp);
      });

      setState(() {
        _users = loadedUsers;
        _filteredUsers = loadedUsers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching users: $e")),
      );
    }
  }

  void _filterUsers(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == "All") {
        _filteredUsers = _users;
      } else {
        _filteredUsers =
            _users.where((user) => user['role'] == filter).toList();
      }
    });
  }

  Future<void> _deleteUser(String userId, String userEmail) async {
    try {
      // Check if current user is trying to delete themselves
      if (_auth.currentUser?.email == userEmail) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("You cannot delete your own account")),
        );
        return;
      }

      // Show confirmation dialog with detailed warning
      bool confirm = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Delete User"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "This will delete the user permanentely.",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  SizedBox(height: 10),
                  Text(
                    "It is an Irreversible process. Do you want to continue with deletion ?",
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text("Delete from Database",
                      style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ) ??
          false;

      if (!confirm) return;

      setState(() {
        _isLoading = true;
      });

      try {
        // Delete from Firestore
        await _firestore.collection('users').doc(userId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "User deleted from database. Note: They can still login with existing credentials."),
            duration: Duration(seconds: 5),
          ),
        );

        // Refresh user list
        await _fetchUsers();
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error deleting user: $error")),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Manage Users",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _filterButton("All", _selectedFilter == "All"),
            _filterButton("User", _selectedFilter == "User"),
            _filterButton("Admin", _selectedFilter == "Admin"),
            _filterButton("Collector", _selectedFilter == "Collector"),
          ],
        ),
        SizedBox(height: 15),
        _isLoading
            ? Center(child: CircularProgressIndicator())
            : _filteredUsers.isEmpty
                ? Center(
                    child: Text(
                      "No users found",
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : Container(
                    height: 400, // Fixed height container instead of Expanded
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: AlwaysScrollableScrollPhysics(),
                      itemCount: _filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = _filteredUsers[index];
                        return Card(
                          elevation: 2,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: user['role'] == 'Admin'
                                  ? Color.fromARGB(1000, 5, 150, 105)
                                  : user['role'] == 'Collector'
                                      ? Colors.teal
                                      : Colors.blue,
                              child: Text(
                                user['name'][0].toUpperCase(),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              user['name'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Email: ${user['email']}"),
                                Text(
                                  "Role: ${user['role']}",
                                  style: TextStyle(
                                    color: user['role'] == 'Admin'
                                        ? Color.fromARGB(1000, 5, 150, 105)
                                        : user['role'] == 'Collector'
                                            ? Colors.teal
                                            : Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  _deleteUser(user['id'], user['email']),
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
                  ),
        SizedBox(height: 10),
        Center(
          child: ElevatedButton.icon(
            onPressed: _fetchUsers,
            icon: Icon(Icons.refresh),
            label: Text("Refresh"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(1000, 5, 150, 105),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _filterButton(String filter, bool isSelected) {
    return ElevatedButton(
      onPressed: () => _filterUsers(filter),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? Color.fromARGB(1000, 5, 150, 105)
            : Colors.grey.shade200,
        foregroundColor: isSelected ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(filter),
    );
  }
}
