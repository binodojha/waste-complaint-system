import 'dart:convert';
import 'dart:io';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:swms/components/map_google.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swms/utils/image_compress.dart';

class ReportForm extends StatefulWidget {
  static String id = 'report_form';
  const ReportForm({super.key});

  @override
  State<ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends State<ReportForm> {
  String? errorImageMesagge;
  final _fireauth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();
  final FocusNode _contactFocusNode = FocusNode();
  final FocusNode _imageFocusNode = FocusNode();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  SingleValueDropDownController wardController =
      SingleValueDropDownController();
  final _reportFormKey = GlobalKey<FormState>();
  String status = 'Pending';
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
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage == null) return null;
      final imageTemporary = File(pickedImage!.path);
      setState(() {
        newImage = imageTemporary;
      });
      // compress image
      File? compressedImage = await compressImage(imageTemporary);
      if (compressedImage == null) return null;
      // Convert to base64
      List<int> imageBytes = await compressedImage.readAsBytes();
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
              focusNode: _titleFocusNode,
              controller: titleController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Title is required';
                }
                if (value.length < 5) {
                  return 'Title must be at least 5 characters';
                }
                return null;
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
              maxLength: 15,
              decoration: InputDecoration(
                hintText: "Title",
                // labelText: "Title",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                errorMaxLines: 2,
              ),
            ),
            TextFormField(
              focusNode: _descriptionFocusNode,
              controller: descriptionController,
              keyboardType: TextInputType.multiline,
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please Enter description!';
                }
                return null;
              },
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
            DropDownTextField(
              controller: wardController,
              dropdownRadius: 8,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please Select a Ward';
                }
                return null;
              },
              textFieldDecoration: InputDecoration(
                  hintText: 'Select a Ward No',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8))),
              dropDownList: [
                DropDownValueModel(name: '1', value: '1'),
                DropDownValueModel(name: '2', value: '2'),
                DropDownValueModel(name: '3', value: '3'),
                DropDownValueModel(name: '4', value: '4'),
                DropDownValueModel(name: '5', value: '5'),
                DropDownValueModel(name: '6', value: '6'),
                DropDownValueModel(name: '7', value: '7'),
                DropDownValueModel(name: '8', value: '8'),
                DropDownValueModel(name: '9', value: '9'),
                DropDownValueModel(name: '10', value: '10'),
                DropDownValueModel(name: '11', value: '11'),
                DropDownValueModel(name: '12', value: '12'),
                DropDownValueModel(name: '13', value: '13'),
                DropDownValueModel(name: '14', value: '14'),
                DropDownValueModel(name: '15', value: '15'),
                DropDownValueModel(name: '16', value: '16'),
                DropDownValueModel(name: '17', value: '17'),
                DropDownValueModel(name: '18', value: '18'),
                DropDownValueModel(name: '19', value: '19'),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              focusNode: _contactFocusNode,
              controller: contactController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Mobile Number",
                prefixIcon: Icon(
                  Icons.phone_android,
                  color: Color.fromARGB(1000, 5, 150, 105),
                ),
                hintText: "Enter your Mobile number here",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Mobile Number is required";
                }
                if (value.length < 10) {
                  return "Mobile Number should contains 10 number";
                }
                if (value.length >= 11) {
                  return "Mobile Number should only contains 10 number";
                }
                return null;
              },
            ),
            SizedBox(
              height: 10,
            ),
            InkWell(
              focusNode: _imageFocusNode,
              onTap: () => {
                showModalBottomSheet(
                    useSafeArea: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    context: context,
                    builder: (context) {
                      return Container(
                        height: 160,
                        width: double.infinity,
                        color: Colors.white,
                        padding: EdgeInsets.only(
                          left: 20,
                          right: 20,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Choose a Image',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
            if (errorImageMesagge != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 6.0),
                child: Text(
                  errorImageMesagge!,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
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
                onPressed: () async {
                  if (_reportFormKey.currentState!.validate()) {
                    setState(() {
                      errorImageMesagge = null;
                    });

                    // Check for image
                    if (newImage == null) {
                      setState(() {
                        errorImageMesagge = 'Please select an image';
                      });
                      return;
                    }
                    try {
                      await _firestore.collection('complaints').add(
                        {
                          'title': titleController.text,
                          'description': descriptionController.text,
                          'location': locationController.text,
                          'status': status,
                          'email': loggedInUser,
                          'collectorEmail': "",
                          'image': base64ImageString,
                          'ward': wardController.dropDownValue!.value,
                          'contact.no': contactController.text,
                          'timestamp': FieldValue.serverTimestamp()
                        },
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      print("Firestore Error: $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Failed to submit report. Please try again.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
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
