import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swms/components/change_password.dart';
import 'package:swms/components/collector_navigation_bar.dart';
import 'package:swms/utils/image_compress.dart';
import 'package:swms/utils/firebase_serivce.dart';
import 'package:swms/screens/login_screen.dart';

class CollectorProfileScreen extends StatefulWidget {
  static const String id = 'collector_profile_screen';
  const CollectorProfileScreen({super.key});
  @override
  State<StatefulWidget> createState() => _CollectorProfileScreen();
}

class _CollectorProfileScreen extends State<CollectorProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final FirebaseSerivce _firebaseService = FirebaseSerivce();
  File? newImage;
  String? base64ImageString;
  String? docId;
  String fullName = "Loading...";
  String email = "Loading...";
  String address = "Loading...";
  String contact = "Loading...";
  String userRole = "Admin";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    final currentUserEmail = _auth.currentUser?.email;
    if (currentUserEmail == null) return;
    try {
      QuerySnapshot userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: currentUserEmail)
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        var userDoc = userQuery.docs.first;

        setState(() {
          docId = userDoc.id;
          base64ImageString = userDoc['image'];
          fullName = userDoc['name'] ?? "No Name Available";
          email = userDoc['email'] ?? "No Email Available";
          address = userDoc['address'] ?? "No Address Available";
          contact = userDoc['contact'] ?? "No Number Available";
          userRole = userDoc['role'] ?? "Collector";
          _isLoading = false;
        });
      } else {
        setState(() {
          fullName = "User Not Found";
          email = "User Not Found";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        fullName = "Error fetching data";
        email = "Error fetching data";
        _isLoading = false;
      });
    }
  }

  Future pickImage(ImageSource source) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage == null) {
        setState(() {
          _isLoading = false;
        });
        return null;
      }

      final imageTemporary = File(pickedImage.path);
      // compress image
      File? compressedImage = await compressImage(imageTemporary);
      if (compressedImage == null) {
        setState(() {
          _isLoading = false;
        });
        return null;
      }

      // Convert to base64
      List<int> imageBytes = await compressedImage.readAsBytes();
      base64ImageString = base64Encode(imageBytes);
      if (docId != null) {
        await _firebaseService.updateUserImage(docId!, base64ImageString!);
        setState(() {
          _isLoading = false;
        });
      } else {
        print("Error: docId is null. Cannot update user image.");
        setState(() {
          _isLoading = false;
        });
      }
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleLogout(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.signOut();
      setState(() {
        _isLoading = false;
      });
      Navigator.pushNamedAndRemoveUntil(
          context, LoginScreen.id, (route) => false);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error logging out. Please try again.")),
      );
    }
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => ChangePasswordDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          bottomNavigationBar: CollectorNavBar(
            currentIndex: 2,
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
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile header section
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.fromARGB(255, 22, 197, 145),
                        Color.fromARGB(255, 5, 150, 105),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "My Profile",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 25),
                      GestureDetector(
                        onTap: () => {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (context) {
                              return Container(
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Change Profile Photo",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Color.fromARGB(1000, 5, 150, 105),
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildImageSourceOption(
                                          icon: Icons.photo_library,
                                          title: "Gallery",
                                          onTap: () {
                                            Navigator.pop(context);
                                            pickImage(ImageSource.gallery);
                                          },
                                        ),
                                        _buildImageSourceOption(
                                          icon: Icons.camera_alt,
                                          title: "Camera",
                                          onTap: () {
                                            Navigator.pop(context);
                                            pickImage(ImageSource.camera);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        },
                        child: Stack(
                          children: [
                            Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                backgroundImage: (base64ImageString != null &&
                                        base64ImageString!.isNotEmpty)
                                    ? MemoryImage(
                                        base64Decode(base64ImageString!))
                                    : null,
                                backgroundColor: Colors.grey[300],
                                radius: 60,
                                child: (base64ImageString == null ||
                                        base64ImageString!.isEmpty)
                                    ? Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.grey[700],
                                      )
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Color.fromARGB(255, 22, 197, 145),
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Color.fromARGB(255, 22, 197, 145),
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(
                        fullName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          userRole,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30),

                // Personal Information Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            color: Color.fromARGB(1000, 5, 150, 105),
                            size: 24,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Personal Information',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      _buildInfoItem(
                        title: 'Full Name',
                        value: fullName,
                        icon: Icons.badge,
                      ),
                      SizedBox(height: 15),
                      _buildInfoItem(
                        title: 'Email',
                        value: email,
                        icon: Icons.email,
                      ),
                      SizedBox(height: 15),
                      _buildInfoItem(
                        title: 'Address',
                        value: address,
                        icon: Icons.location_city,
                      ),
                      SizedBox(height: 15),
                      _buildInfoItem(
                        title: 'Contact Number',
                        value: contact,
                        icon: Icons.phone,
                      ),
                      SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _showChangePasswordDialog,
                          icon: Icon(
                            Icons.lock_outline,
                            color: Colors.white,
                          ),
                          label: Text('Change Password'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 22, 197, 145),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Logout Button
                      Container(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _handleLogout(context),
                          icon: Icon(
                            Icons.logout,
                            color: Colors.white,
                          ),
                          label: Text('Log Out'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black54,
            child: Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(1000, 5, 150, 105),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 231, 229, 229),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Color.fromARGB(1000, 5, 150, 105),
              size: 30,
            ),
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 234, 231, 231),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Color.fromARGB(1000, 5, 150, 105),
              size: 24,
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
