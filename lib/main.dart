import 'package:flutter/material.dart';
import 'package:swms/screens/home_screen.dart';
import 'package:swms/screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey),
      child: SafeArea(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              appBarTheme: AppBarTheme(backgroundColor: Colors.white),
              bottomNavigationBarTheme:
                  BottomNavigationBarThemeData(backgroundColor: Colors.white),
              scaffoldBackgroundColor: Colors.blueGrey[50]),
          home: LoginScreen(),
        ),
      ),
    );
  }
}
