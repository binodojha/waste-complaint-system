import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:swms/components/user_navigation_bar.dart';
import 'package:swms/screens/login_screen.dart';
import 'package:swms/utils/image_compress.dart';
import 'package:swms/utils/firebase_serivce.dart';

class UserProfileScreen extends StatefulWidget {
  static const String id = 'user_profile_screen';
  const UserProfileScreen({super.key});
  @override
  State<StatefulWidget> createState() => _UserProfileScreen();
}

class _UserProfileScreen extends State<UserProfileScreen> {
  final String? currentUserEmail = FirebaseAuth.instance.currentUser?.email;
  final _firestore = FirebaseFirestore.instance;
  final FirebaseSerivce _firebaseService = FirebaseSerivce();
  File? newImage;
  String? base64ImageString;
  String? docId;
  String fullName = "Loading...";
  String email = "Loading...";

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
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
        });
      } else {
        setState(() {
          fullName = "User Not Found";
          email = "User Not Found";
        });
      }
    } catch (e) {
      setState(() {
        fullName = "Error fetching data";
        email = "Error fetching data";
      });
    }
  }

  Future pickImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage == null) return null;
      final imageTemporary = File(pickedImage.path);
      // compress image
      File? compressedImage = await compressImage(imageTemporary);
      if (compressedImage == null) return null;
      // Convert to base64
      List<int> imageBytes = await compressedImage.readAsBytes();
      base64ImageString = base64Encode(imageBytes);
      if (docId != null) {
        await _firebaseService.updateUserImage(docId!, base64ImageString!);
        setState(() {}); // Refresh UI
      } else {
        print("Error: docId is null. Cannot update user image.");
      }
    } on PlatformException catch (e) {
      print('failed to pick image:$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: UserNavBar(
        currentIndex: 2,
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
            // CircleAvatar(
            //     // backgroundImage: AssetImage(''),
            //     ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.maxFinite,
              padding: EdgeInsets.only(top: 10, bottom: 20),
              color: Color.fromARGB(255, 22, 197, 145),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "My Profile",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  InkWell(
                    onTap: () => {
                      showModalBottomSheet(
                          useSafeArea: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          context: context,
                          builder: (context) {
                            return Container(
                              height: 120,
                              width: double.infinity,
                              color: Color.fromARGB(1000, 5, 150, 105),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  imagePickButton(
                                    title: "Gallery",
                                    icon: Icons.image_sharp,
                                    onClicked: () =>
                                        pickImage(ImageSource.gallery),
                                  ),
                                  imagePickButton(
                                      title: "Camera",
                                      icon: Icons.camera_alt,
                                      onClicked: () =>
                                          pickImage(ImageSource.camera)),
                                ],
                              ),
                            );
                          })
                    },
                    child: CircleAvatar(
                      backgroundImage: (base64ImageString != null &&
                              base64ImageString!.isNotEmpty)
                          ? MemoryImage(base64Decode(base64ImageString!))
                          : null,
                      radius: 50,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 20, right: 20, top: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    padding:
                        EdgeInsets.only(left: 4, right: 4, top: 5, bottom: 5),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Full Name:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(fullName),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    padding:
                        EdgeInsets.only(left: 4, right: 4, top: 5, bottom: 5),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(6))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Email:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(email),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 20, right: 20, top: 30, bottom: 70),
            width: double.maxFinite,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, LoginScreen.id);
              },
              style: ElevatedButton.styleFrom(
                textStyle: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                padding: EdgeInsets.all(15),
                shape: BeveledRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                foregroundColor: Colors.white,
                backgroundColor: Color.fromARGB(255, 235, 22, 6),
              ),
              child: Text('Log Out'),
            ),
          ),
        ],
      ),
    );
  }
}

Widget imagePickButton({
  required String title,
  required IconData icon,
  required VoidCallback onClicked,
}) {
  return Padding(
    padding: EdgeInsets.only(
      left: 10.0,
      top: 5.0,
      bottom: 5.0,
    ),
    child: ElevatedButton(
      onPressed: onClicked,
      style: ElevatedButton.styleFrom(
        iconSize: 30,
        iconColor: Colors.black,
        backgroundColor: Color.fromARGB(255, 70, 255, 196),
        shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.circular(2.0),
        ),
      ),
      child: Row(
        spacing: 15.0,
        children: [
          Icon(
            icon,
          ),
          Text(title,
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
              )),
        ],
      ),
    ),
  );
}
