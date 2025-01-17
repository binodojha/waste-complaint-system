import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:swms/screens/home_screen.dart';
import 'package:swms/screens/login_screen.dart';
import 'package:swms/screens/registration_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey[300]),
      child: SafeArea(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              appBarTheme: AppBarTheme(backgroundColor: Colors.white),
              bottomNavigationBarTheme:
                  BottomNavigationBarThemeData(backgroundColor: Colors.white),
              scaffoldBackgroundColor: Colors.blueGrey[50]),
          initialRoute: UserHomeScreen.id,
          routes: {
            LoginScreen.id: (context) => LoginScreen(),
            RegistrationScreen.id: (context) => RegistrationScreen(),
            UserHomeScreen.id: (context) => UserHomeScreen(),
          },
        ),
      ),
    );
  }
}
