import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swms/components/admin_navigation_bar.dart';

class UserManageScreen extends StatefulWidget {
  static const String id = 'user_manage_screen';
  const UserManageScreen({super.key});
  @override
  State<StatefulWidget> createState() => _UserManageScreenState();
}

class _UserManageScreenState extends State<UserManageScreen> {
  final _auth = FirebaseAuth.instance;
  final String? currenUserEmail = FirebaseAuth.instance.currentUser!.email;
  final _firestore = FirebaseFirestore.instance;
  final _addUserFormKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  SingleValueDropDownController roleController =
      SingleValueDropDownController();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        bottomNavigationBar: AdminNavBar(
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
        body: Container(
          margin: EdgeInsets.only(left: 20, right: 20, top: 30),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Add a User",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Form(
                  key: _addUserFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        focusNode: _nameFocusNode,
                        controller: nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Full Name",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        focusNode: _emailFocusNode,
                        controller: emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Enter Email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        focusNode: _passwordFocusNode,
                        controller: passwordController,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.length < 8) {
                            return 'Please enter password with at least 8 characters';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Enter Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      DropDownTextField(
                        controller: roleController,
                        dropdownRadius: 8,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Select a Role';
                          }
                        },
                        textFieldDecoration: InputDecoration(
                            hintText: 'Select a Role',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8))),
                        dropDownList: [
                          DropDownValueModel(name: 'Admin', value: 'Admin'),
                          DropDownValueModel(
                              name: 'Collector', value: 'Collector'),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: double.maxFinite,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_addUserFormKey.currentState!.validate()) {
                              try {
                                final newUser =
                                    await _auth.createUserWithEmailAndPassword(
                                        email: emailController.text,
                                        password: passwordController.text);
                                _firestore.collection('users').add(
                                  {
                                    'name': nameController.text,
                                    'email': emailController.text,
                                    'password': passwordController.text,
                                    'role': roleController.dropDownValue!.value,
                                    'timestamp': FieldValue.serverTimestamp()
                                  },
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("User Added successfully"),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(
                                    "Error while adding User",
                                    style: TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                ));
                              }
                              nameController.clear();
                              emailController.clear();
                              passwordController.clear();
                              roleController.clearDropDown();
                            }
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
                            backgroundColor: Color.fromARGB(1000, 5, 150, 105),
                          ),
                          child: Text('Add  User'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
