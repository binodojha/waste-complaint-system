import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swms/screens/admin/admin_screen.dart';
import 'package:swms/screens/collector/collector_home_screen.dart';
import 'package:swms/screens/login_screen.dart';
import 'package:swms/screens/user/user_home_screen.dart';
import 'package:swms/utils/firebase_serivce.dart';

class Wrapper extends StatefulWidget {
  static String id = 'wrapper';
  const Wrapper({super.key});

  @override
  State<StatefulWidget> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  final FirebaseSerivce _firebaseService = FirebaseSerivce();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator()); // Show loading indicator
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return LoginScreen();
        }

        String? currentUserEmail = snapshot.data?.email;
        if (currentUserEmail == null) {
          return LoginScreen();
        }

        return FutureBuilder<String>(
          future:
              _firebaseService.getUserRole(currentUserEmail), // Fetch user role
          builder: (context, roleSnapshot) {
            // if (roleSnapshot.connectionState == ConnectionState.waiting) {
            //   return const Center(child: CircularProgressIndicator());
            // }
            if (roleSnapshot.hasError || !roleSnapshot.hasData) {
              return LoginScreen();
            }
            String userRole = roleSnapshot.data!;
            if (userRole == 'Admin') {
              return AdminScreen();
            } else if (userRole == 'Collector') {
              return CollectorHomeScreen();
            } else {
              return UserHomeScreen();
            }
          },
        );
      },
    );
  }
}
