import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swms/components/admin_navigation_bar.dart';

class AdminScreen extends StatefulWidget {
  static String id = 'admin_dashboard_screen';
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: AdminNavBar(),
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
        decoration: BoxDecoration(),
        margin: EdgeInsets.only(left: 20, right: 20, top: 30),
        child: Text('data'),
      ),
    );
  }
}
