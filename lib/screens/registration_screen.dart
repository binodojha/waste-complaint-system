import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swms/screens/login_screen.dart';
import 'package:swms/screens/user/user_home_screen.dart';

class RegistrationScreen extends StatefulWidget {
  static String id = 'registration_screen';
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _regFormKey = GlobalKey<FormState>();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmpasswordFocusNode = FocusNode();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController confirmpasswordController =
      TextEditingController();
  bool _obscureText = true;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.only(left: 20, right: 20, bottom: 70),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 200,
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    "Create an Account",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Form(
                    key: _regFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          focusNode: _nameFocusNode,
                          controller: nameController,
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                            labelText: "Full Name",
                            prefixIcon: Icon(
                              Icons.person,
                              color: Color.fromARGB(1000, 5, 150, 105),
                            ),
                            hintText: "Enter your Name here",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: Colors.grey[200],
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Name is required";
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          focusNode: _emailFocusNode,
                          decoration: InputDecoration(
                            labelText: "Email",
                            prefixIcon: Icon(
                              Icons.person,
                              color: Color.fromARGB(1000, 5, 150, 105),
                            ),
                            hintText: "Enter your Email here",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: Colors.grey[200],
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Email is required";
                            }
                            final emailRegex = RegExp(
                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                            if (!emailRegex.hasMatch(value)) {
                              return "Enter a valid email";
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          focusNode: _passwordFocusNode,
                          controller: passwordController,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Color.fromARGB(1000, 5, 150, 105),
                            ),
                            suffixIcon: InkWell(
                              onTap: () {
                                if (_obscureText) {
                                  _obscureText = false;
                                  setState(() {});
                                } else {
                                  _obscureText = true;
                                  setState(() {});
                                }
                              },
                              child: Icon(
                                color: Color.fromARGB(1000, 5, 150, 105),
                                Icons.remove_red_eye,
                              ),
                            ),
                            hintText: "Enter your Password here",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: Colors.grey[200],
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Password is required";
                            }
                            if (value.length < 8) {
                              return "Password must be at least 8 characters";
                            }
                            if (!RegExp(r'^(?=.*[A-Z])').hasMatch(value)) {
                              return "Include at least one uppercase letter";
                            }
                            if (!RegExp(r'^(?=.*[a-z])').hasMatch(value)) {
                              return "Include at least one lowercase letter";
                            }
                            if (!RegExp(r'^(?=.*\d)').hasMatch(value)) {
                              return "Include at least one number";
                            }
                            if (!RegExp(r'^(?=.*[@$!%*?&])').hasMatch(value)) {
                              return "Include at least one special character (@\$!%*?&)";
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          focusNode: _confirmpasswordFocusNode,
                          controller: confirmpasswordController,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: "Confirm Password",
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Color.fromARGB(1000, 5, 150, 105),
                            ),
                            suffixIcon: InkWell(
                              onTap: () {
                                if (_obscureText) {
                                  _obscureText = false;
                                  setState(() {});
                                } else {
                                  _obscureText = true;
                                  setState(() {});
                                }
                              },
                              child: Icon(
                                color: Color.fromARGB(1000, 5, 150, 105),
                                Icons.remove_red_eye,
                              ),
                            ),
                            hintText: "Enter your Password here",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: Colors.grey[200],
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Password is required";
                            }
                            if (value != passwordController.text) {
                              return "password does not match";
                            }
                          },
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_regFormKey.currentState!.validate()) {
                                try {
                                  final newUser = await _auth
                                      .createUserWithEmailAndPassword(
                                          email: emailController.text,
                                          password: passwordController.text);
                                  _firestore.collection('users').add(
                                    {
                                      'name': nameController.text.trim(),
                                      'email': emailController.text.trim(),
                                      'password':
                                          passwordController.text.trim(),
                                      'role': 'User',
                                      'image': null,
                                      'timestamp': FieldValue.serverTimestamp()
                                    },
                                  );
                                  if (newUser.user != null) {
                                    Navigator.pushNamed(
                                        context, UserHomeScreen.id);
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          "Unexpected Error: User Registration Failed!"),
                                    ),
                                  );
                                }
                                emailController.clear();
                                nameController.clear();
                                passwordController.clear();
                                confirmpasswordController.clear();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              textStyle: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                              padding: EdgeInsets.all(15),
                              shape: BeveledRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                              foregroundColor: Colors.white,
                              backgroundColor:
                                  Color.fromARGB(1000, 5, 150, 105),
                            ),
                            child: Text("Register"),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, LoginScreen.id);
                    },
                    child: Text(
                      'Already a User? Log In',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
