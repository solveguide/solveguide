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
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => IssueData(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightMode,
        initialRoute: '/',
        routes: {
          '/': (context) => AuthWrapper(),
          '/dashboard': (context) => DashboardPage(),
          '/demo': (context) => HomePage(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          return DashboardPage(); // User is logged in, show Dashboard
        } else {
          return HomePage(); // User is not logged in, show Demo
        }
      },
    );
  }
}
