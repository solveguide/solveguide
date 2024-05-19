import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:guide_solve/data/issue_data.dart';
import 'package:guide_solve/pages/dashboard_page.dart';
import 'package:guide_solve/themes/light_mode.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'pages/home_page.dart';
import 'dart:html' as html;

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
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _handleIncomingLinks();
  }

  void _handleIncomingLinks() async {
    // Listen for auth state changes
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        print("User is signed in!");
      }
    });

    final String currentUrl = html.window.location.href;

    // Check if the app was launched with an email link
    if (_auth.isSignInWithEmailLink(currentUrl)) {
      _handleEmailLinkSignIn(currentUrl);
    }
  }

  void _handleEmailLinkSignIn(String link) async {
    try {
      // Retrieve the email from storage or prompt the user
      final email = await _getEmailFromStorage();
      if (email != null) {
        await _auth.signInWithEmailLink(email: email, emailLink: link);
        print("Successfully signed in with email link!");
        // Navigate to the Dashboard after successful sign-in
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        print("No email found to sign in with.");
      }
    } catch (e) {
      print("Error signing in with email link: $e");
    }
  }

  Future<String?> _getEmailFromStorage() async {
    // Implement this method to retrieve the stored email
    // For demonstration, we'll return a hardcoded email
    return "user@example.com";
  }

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
