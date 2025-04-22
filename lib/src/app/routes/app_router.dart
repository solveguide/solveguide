import 'package:go_router/go_router.dart';
import 'package:guide_solve/pages/contact_page.dart';
import 'package:guide_solve/pages/dashboard_page.dart';
import 'package:guide_solve/pages/home_page.dart';
import 'package:guide_solve/pages/profile_page.dart';
import 'package:guide_solve/src/app/routes/routes.dart';
import 'package:guide_solve/src/auth/auth.dart';
import 'package:guide_solve/src/auth/view/magic_login_view.dart';

class AppRouter {
  final router = GoRouter(
    initialLocation: AppRoutes.magicLogin.route,
    routes: [
      GoRoute(
        path: AppRoutes.home.route,
        name: AppRoutes.home.name,
        builder: (context, state) => HomePage(),
      ),
      GoRoute(
        path: AppRoutes.profile.route,
        name: AppRoutes.profile.name,
        builder: (context, state) => ProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.contact.route,
        name: AppRoutes.contact.name,
        builder: (context, state) => ContactPage(),
      ),
      GoRoute(
        path: AppRoutes.dashboard.route,
        name: AppRoutes.dashboard.name,
        builder: (context, state) => DashboardPage(),
      ),
      GoRoute(
        path: AppRoutes.login.route,
        name: AppRoutes.login.name,
        builder: (context, state) => LoginView(),
      ),
      GoRoute(
        path: AppRoutes.magicLogin.route,
        name: AppRoutes.magicLogin.name,
        builder: (context, state) {
          final magicLink = state.uri.toString();
          print('Full URL: ${state.uri}');
          print('Query Parameters: ${state.uri.queryParameters}');
          return MagicLoginView(magicLink: magicLink);
        },
      ),
    ],
  );
}
