import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swms/screens/admin/admin_screen.dart';
import 'package:swms/screens/collector/collector_home_screen.dart';
import 'package:swms/screens/user/user_home_screen.dart';
import 'package:swms/screens/registration_screen.dart';

class LoginScreen extends StatefulWidget {
  static String id = 'login_screen';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _loginFormKey = GlobalKey<FormState>();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final loggedInUser = FirebaseAuth.instance.currentUser?.email!;
  bool _obscureText = true;
  Icon icon = Icon(
    color: Color.fromARGB(1000, 5, 150, 105),
    Icons.remove_red_eye,
  );
  bool _isLoading = false;
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
                    "Welcome Back",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Form(
                    key: _loginFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          focusNode: _emailFocusNode,
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: "Email",
                            prefixIcon: Icon(
                              Icons.email,
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
                              return "Please enter email";
                            }
                            final emailRegex = RegExp(
                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                            if (!emailRegex.hasMatch(value)) {
                              return "Enter a valid email";
                            }
                          },
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          focusNode: _passwordFocusNode,
                          obscureText: _obscureText,
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: Icon(
                              color: Color.fromARGB(1000, 5, 150, 105),
                              Icons.lock,
                            ),
                            suffixIcon: InkWell(
                                onTap: () {
                                  _obscureText = !_obscureText;
                                  icon = _obscureText
                                      ? const Icon(
                                          Icons.visibility,
                                          color:
                                              Color.fromARGB(1000, 5, 150, 105),
                                        )
                                      : const Icon(
                                          Icons.visibility_off,
                                        );
                                  setState(() {});
                                },
                                child: icon),
                            hintText: "Enter your Password",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter password";
                            }
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    if (_loginFormKey.currentState!
                                        .validate()) {
                                      setState(() {
                                        _isLoading = true;
                                      });

                                      try {
                                        final user = await _auth
                                            .signInWithEmailAndPassword(
                                          email: emailController.text.trim(),
                                          password:
                                              passwordController.text.trim(),
                                        );
                                        final currentUser = _auth.currentUser;
                                        if (currentUser != null) {
                                          // Query Firestore to get user document by email
                                          final querySnapshot = await _firestore
                                              .collection('users')
                                              .where('email',
                                                  isEqualTo: currentUser.email)
                                              .limit(1) // Get only one result
                                              .get();

                                          if (querySnapshot.docs.isNotEmpty) {
                                            final userData =
                                                querySnapshot.docs.first.data();
                                            final role = userData['role'];
                                            if (role == 'Admin') {
                                              Navigator.pushNamed(
                                                  context, AdminScreen.id);
                                            } else if (role == 'Collector') {
                                              Navigator.pushNamed(context,
                                                  CollectorHomeScreen.id);
                                            } else {
                                              Navigator.pushNamed(
                                                  context, UserHomeScreen.id);
                                            }
                                          }
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                "Incorrect Email/Password"),
                                            duration: Duration(seconds: 3),
                                          ),
                                        );
                                      } finally {
                                        setState(() {
                                          _isLoading = false;
                                        });
                                      }
                                    }
                                    emailController.clear();
                                    passwordController.clear();
                                  },
                            style: ElevatedButton.styleFrom(
                              textStyle: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                              padding: EdgeInsets.all(15),
                              shape: BeveledRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                              iconColor: Colors.white,
                              foregroundColor: Colors.white,
                              backgroundColor:
                                  Color.fromARGB(1000, 5, 150, 105),
                            ),
                            child: Text("Log In"),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, RegistrationScreen.id);
                      },
                      style: ElevatedButton.styleFrom(
                        textStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                        padding: EdgeInsets.all(15),
                        shape: BeveledRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                        iconColor: Colors.white,
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.grey,
                      ),
                      child: Text("Register"),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  if (_isLoading)
                    BackdropFilter(
                      filter: ImageFilter.blur(
                          sigmaX: 0.5, sigmaY: 0.5), // Adds blur effect
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(
                                    color: Color.fromARGB(1000, 5, 150, 105),
                                    strokeWidth: 3,
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    'Logging in...',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
