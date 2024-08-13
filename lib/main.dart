import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/bloc/auth/auth_bloc.dart';
import 'package:guide_solve/bloc/issue/issue_bloc.dart';
//import 'package:guide_solve/components/app_bloc_observer.dart';
import 'package:guide_solve/pages/dashboard_page.dart';
import 'package:guide_solve/repositories/auth_repository.dart';
import 'package:guide_solve/repositories/issue_repository.dart';
import 'package:guide_solve/themes/light_mode.dart';
import 'firebase_options.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //Bloc.observer = AppBlocObserver();
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              AuthBloc(authRepository: AuthRepository())..add(AppStarted()),
        ),
        BlocProvider(
          create: (context) => IssueBloc(IssueRepository()),
        ),
      ],
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
        // Show a loading indicator while waiting for authentication state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Check if the user is logged in
        if (snapshot.hasData) {
          final user = snapshot.data;

          // Check if the user is not null and not anonymous
          if (user != null && !user.isAnonymous) {
            // Navigate to the dashboard
            return const DashboardPage(); // Replace with your DashboardPage widget
          } else {
            // User is logged in anonymously
            return const HomePage(); // Replace with your DemoPage widget
          }
        } else {
          // User is not logged in
          return const HomePage(); // Replace with your DemoPage widget
        }
      },
    );
  }
}
