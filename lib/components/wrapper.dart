import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swms/screens/admin/admin_screen.dart';
import 'package:swms/screens/login_screen.dart';
import 'package:swms/screens/user/user_home_screen.dart';

class Wrapper extends StatefulWidget {
  static String id = 'wrapper';
  const Wrapper({super.key});

  @override
  State<StatefulWidget> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return AdminScreen();
          } else {
            return LoginScreen();
          }
        });
  }
}
