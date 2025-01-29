import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:swms/components/map_google.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class ReportForm extends StatefulWidget {
  static String id = 'report_form';
  const ReportForm({super.key});

  @override
  State<ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends State<ReportForm> {
  final _fireauth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  final _reportFormKey = GlobalKey<FormState>();
  String status = 'pending';
  String? loggedInUser;
  File? newImage;
  String? base64ImageString;
  @override
  void initState() {
    super.initState();
    loggedInUser = _fireauth.currentUser?.email;
  }

  void updateLocation(String newLocation) {
    locationController.text = newLocation;
  }

  Future pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      final imageTemporary = File(image!.path);
      setState(() {
        newImage = imageTemporary;
      });
      List<int> imageBytes = File(newImage!.path).readAsBytesSync();
      base64ImageString = base64Encode(imageBytes);
    } on PlatformException catch (e) {
      print('failed to pick image:$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      title: Row(
        children: [
          Icon(Icons.report),
          SizedBox(
            width: 10,
          ),
          Text("Report A Waste"),
        ],
      ),
      content: Form(
        key: _reportFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: titleController,
              validator: (value) {
                if (value == null || value.isEmpty || value.length < 5) {
                  return 'Please enter some text';
                }
                return null;
              },
              maxLength: 15,
              decoration: InputDecoration(
                hintText: "Title",
                // labelText: "Title",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            TextFormField(
              controller: descriptionController,
              keyboardType: TextInputType.multiline,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Description",
                // labelText: "Title",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(
              height: 10,
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
                              onClicked: () => pickImage(ImageSource.gallery),
                            ),
                            imagePickButton(
                                title: "Camera",
                                icon: Icons.camera_alt,
                                onClicked: () => pickImage(ImageSource.camera)),
                          ],
                        ),
                      );
                    })
              },
              child: Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blueGrey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: newImage != null
                    ? Image.file(
                        newImage!,
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Upload Image",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Icon(
                              Icons.image,
                              size: 30,
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a location';
                }
                return null;
              },
              controller: locationController,
              readOnly: true,
              decoration: InputDecoration(
                hintText: "Location",
                // labelText: "Title",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              height: 300,
              child: Map(
                onLocationSelected: updateLocation,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_reportFormKey.currentState!.validate()) {
                    _firestore.collection('complaints').add(
                      {
                        'title': titleController.text,
                        'description': descriptionController.text,
                        'location': locationController.text,
                        'status': status,
                        'email': loggedInUser,
                        'image': base64ImageString ?? "",
                        'timestamp': FieldValue.serverTimestamp()
                      },
                    );
                  }
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  textStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                  padding: EdgeInsets.all(15),
                  shape: BeveledRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  foregroundColor: Colors.white,
                  backgroundColor: Color.fromARGB(1000, 5, 150, 105),
                ),
                child: Text("Submit"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Image Pick Button
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
