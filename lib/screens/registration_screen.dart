import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swms/screens/home_screen.dart';

class RegistrationScreen extends StatefulWidget {
  static String id = 'registration_screen';
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
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
                  "Create an Account",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                // SizedBox(
                //   height: 20,
                // ),
                // TextField(
                //   controller: emailController,
                //   keyboardType: TextInputType.emailAddress,
                //   decoration: InputDecoration(
                //     labelText: "Name",
                //     prefixIcon: Icon(
                //       Icons.person,
                //       color: Color.fromARGB(1000, 5, 150, 105),
                //     ),
                //     hintText: "Enter your Name here",
                //     border: OutlineInputBorder(
                //         borderRadius: BorderRadius.circular(10)),
                //     filled: true,
                //     fillColor: Colors.grey[200],
                //   ),
                // ),
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
                  controller: passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Color.fromARGB(1000, 5, 150, 105),
                    ),
                    hintText: "Enter your Password here",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                SizedBox(
                  height: 15,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        final newUser =
                            await _auth.createUserWithEmailAndPassword(
                                email: emailController.text,
                                password: passwordController.text);
                        if (newUser != null) {
                          Navigator.pushNamed(context, UserHomeScreen.id);
                        }
                      } catch (e) {
                        print(e);
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
                      backgroundColor: Color.fromARGB(1000, 5, 150, 105),
                    ),
                    child: Text("Register"),
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
