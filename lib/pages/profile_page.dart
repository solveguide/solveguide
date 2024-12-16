import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/bloc/auth/auth_bloc.dart';
import 'package:guide_solve/src/auth/view/login_view.dart';
import 'package:guide_solve/src/components/logo.dart';
import 'package:guide_solve/src/components/my_navigation_drawer.dart';
import 'package:guide_solve/src/components/plain_button.dart';
import 'package:guide_solve/pages/dashboard_page.dart';
import 'package:guide_solve/pages/home_page.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  //controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final currentAppUser = context.read<AuthBloc>().currentAppUser!;
    return AppScaffold(
      releaseFocus: true,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        //backgroundColor: Colors.orange[50],
        title: const Text('Your Account'),
      ),
      drawer: const MyNavigationDrawer(),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute<Widget>(
                builder: (context) => LoginView(),
              ),
              (route) => false,
            );
          } else if (state is AuthInitial) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute<Widget>(
                builder: (context) => const HomePage(),
              ),
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const CircularProgressIndicator();
          }
          return Center(
            child: Column(
              children: [
                // Logo
                Tappable(
                  onTap: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute<Widget>(
                      builder: (context) => const DashboardPage(),
                    ),
                    (route) => false,
                  ),
                  child: ShadCard(
                    backgroundColor: AppColors.consensus,
                    width: 300,
                    child: logoTitle(10),
                  ),
                ),
                const SizedBox(height: 50),

                // Welcome message
                const Text(
                  'Account Details',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 25),

                // Displaying email
                Text(
                  'Email: ${currentAppUser.email}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),

                // Displaying username
                Text(
                  'Username: ${currentAppUser.username}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),

                // Displaying total contacts count
                Text(
                  'Total Contacts: ${currentAppUser.contacts.length}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),

                // Displaying total invited contacts count
                Text(
                  'Invited Contacts: ${currentAppUser.invitedContacts.length}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),

                // Displaying issue area labels
                const Text(
                  'Issue Areas:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                ...currentAppUser.issueAreaLabels.map(
                  (label) => Text(
                    label,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 25),

                // Sign out button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PlainButton(
                      onPressed: () {
                        BlocProvider.of<AuthBloc>(context).add(
                          const AuthLogoutRequested(),
                        );
                      },
                      text: 'Sign Out',
                    ),
                    const SizedBox(width: 25),
                  ],
                ),
                const SizedBox(height: 25),
              ],
            ),
          );
        },
      ),
    );
  }
}
