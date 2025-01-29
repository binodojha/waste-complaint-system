import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swms/screens/admin/admin_screen.dart';
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
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final loggedInUser = FirebaseAuth.instance.currentUser?.email!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
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
                ),
                SizedBox(
                  height: 15,
                ),
                TextField(
                  obscureText: true,
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: Icon(
                      color: Color.fromARGB(1000, 5, 150, 105),
                      Icons.lock,
                    ),
                    suffixIcon: Icon(
                      color: Color.fromARGB(1000, 5, 150, 105),
                      Icons.remove_red_eye,
                    ),
                    hintText: "Enter your Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        final user = await _auth.signInWithEmailAndPassword(
                          email: emailController.text,
                          password: passwordController.text,
                        );
                        if (user != null) {
                          if (loggedInUser == 'binodojha1@gmail.com') {
                            Navigator.pushNamed(context, AdminScreen.id);
                          } else {
                            Navigator.pushNamed(context, UserHomeScreen.id);
                          }
                        }
                      } catch (e) {
                        // exception handling
                      }
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
                      backgroundColor: Color.fromARGB(1000, 5, 150, 105),
                    ),
                    child: Text("Log In"),
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
                InkWell(
                  onTap: () {},
                  child: Text(
                    "Forget Password?",
                    style: TextStyle(decoration: TextDecoration.underline),
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
