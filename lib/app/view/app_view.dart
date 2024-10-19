import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/bloc/auth/auth_bloc.dart';
import 'package:guide_solve/bloc/issue/issue_bloc.dart';
import 'package:guide_solve/pages/dashboard_page.dart';
import 'package:guide_solve/pages/home_page.dart';
import 'package:guide_solve/pages/login_page.dart';
import 'package:guide_solve/pages/profile_page.dart';
import 'package:guide_solve/repositories/appUser_repository.dart';
import 'package:guide_solve/repositories/auth_repository.dart';
import 'package:guide_solve/repositories/issue_repository.dart';
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
        Provider<AppUserRepository>(
          create: (_) => AppUserRepository(),
        ),
        BlocProvider<AuthBloc>(
          create: (context) =>
              AuthBloc(authRepository: authRepository)..add(const AppStarted()),
        ),
        BlocProvider<IssueBloc>(
          create: (context) => IssueBloc(issueRepository, authRepository),
        ),
      ],
      child: ShadApp.material(
        debugShowCheckedModeBanner: false,
        title: 'Solve Guide',
        themeMode: ThemeMode.light,
        theme: const AppTheme().theme,
        darkTheme: const AppDarkTheme().theme,
        materialThemeBuilder: (context, theme) {
          return theme.copyWith(
            appBarTheme: const AppBarTheme(
              surfaceTintColor: AppColors.transparent,
            ),
            textTheme: theme.brightness == Brightness.light
                ? const AppTheme().textTheme
                : const AppDarkTheme().textTheme,
            snackBarTheme: const SnackBarThemeData(
              behavior: SnackBarBehavior.floating,
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              type: BottomNavigationBarType.fixed,
            ),
          );
        },
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
