import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:swms/components/waste_report_form.dart';
import 'package:swms/components/wrapper.dart';
import 'package:swms/screens/admin/admin_screen.dart';
import 'package:swms/screens/admin/user_manage_screen.dart';
import 'package:swms/screens/admin/admin_profile_screen.dart';
import 'package:swms/screens/user/user_all_reports_screen.dart';
import 'package:swms/screens/user/user_home_screen.dart';
import 'package:swms/screens/login_screen.dart';
import 'package:swms/screens/registration_screen.dart';
import 'package:swms/screens/admin/complaint_screen.dart';
import 'package:swms/screens/user/user_profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Failed to initialize Firebase: $e');
  }
  runApp(MyApp());
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
          initialRoute: LoginScreen.id,
          routes: {
            Wrapper.id: (context) => Wrapper(),
            LoginScreen.id: (context) => LoginScreen(),
            RegistrationScreen.id: (context) => RegistrationScreen(),
            // Admin Screen
            AdminScreen.id: (context) => AdminScreen(),
            AdminProfileScreen.id: (context) => AdminProfileScreen(),
            UserManageScreen.id: (context) => UserManageScreen(),
            AdminComplaintScreen.id: (context) => AdminComplaintScreen(),
            // User Screen
            UserHomeScreen.id: (context) => UserHomeScreen(),
            UserProfileScreen.id: (context) => UserProfileScreen(),
            UserReports.id: (context) => UserReports(),
            ReportForm.id: (context) => ReportForm(),
          },
        ),
      ),
    );
  }
}
