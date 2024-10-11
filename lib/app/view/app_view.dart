import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/bloc/auth/auth_bloc.dart';
import 'package:guide_solve/bloc/issue/issue_bloc.dart';
import 'package:guide_solve/pages/dashboard_page.dart';
import 'package:guide_solve/pages/home_page.dart';
import 'package:guide_solve/pages/login_page.dart';
import 'package:guide_solve/pages/profile_page.dart';
import 'package:guide_solve/repositories/auth_repository.dart';
import 'package:guide_solve/repositories/issue_repository.dart';
import 'package:guide_solve/themes/light_mode.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create single instances of repositories
    final authRepository = AuthRepository();
    final issueRepository = IssueRepository();

    return MultiProvider(
      providers: [
        Provider<AuthRepository>.value(
          value: authRepository,
        ),
        Provider<IssueRepository>.value(
          value: issueRepository,
        ),
        BlocProvider<AuthBloc>(
          create: (context) =>
              AuthBloc(authRepository: authRepository)..add(const AppStarted()),
        ),
        BlocProvider<IssueBloc>(
          create: (context) => IssueBloc(issueRepository, authRepository),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightMode,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthSuccess) {
              return const DashboardPage();
            } else {
              return const HomePage();
            }
          },
        ),
        routes: {
          '/dashboard': (context) => const DashboardPage(),
          '/login': (context) => LoginPage(),
          '/profile': (context) => ProfilePage(),
        },
      ),
    );
  }
}