import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:guide_solve/data/issue_data.dart';
import 'package:guide_solve/pages/dashboard_page.dart';
import 'package:guide_solve/themes/light_mode.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => IssueData(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightMode,
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthWrapper(),
          '/dashboard': (context) => const DashboardPage(),
          '/demo': (context) => const HomePage(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        print('Auth state changed: ${snapshot.connectionState}');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          print('User is logged in');
          // Navigate to dashboard
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          });
          return Container(); // Return an empty container while navigation happens
        } else {
          print('User is not logged in');
          // Navigate to home
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/demo');
          });
          return Container(); // Return an empty container while navigation happens
        }
      },
    );
  }
}