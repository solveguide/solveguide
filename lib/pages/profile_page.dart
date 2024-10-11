import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/bloc/auth/auth_bloc.dart';
import 'package:guide_solve/components/logo.dart';
import 'package:guide_solve/components/my_navigation_drawer.dart';
import 'package:guide_solve/components/plain_button.dart';
import 'package:guide_solve/pages/home_page.dart';
import 'package:guide_solve/pages/login_page.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  //controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        backgroundColor: Colors.orange[50],
        title: const Text('Your Account'),
      ),
      drawer: const MyNavigationDrawer(),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute<Widget>(
                  builder: (context) => LoginPage(),
                ),
                (route) => false,);
          } else if (state is AuthInitial) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute<Widget>(
                  builder: (context) => const HomePage(),
                ),
                (route) => false,);
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const CircularProgressIndicator();
          }
          return Center(
            child: Column(
              children: [
                //logo
                logoTitle(10),
                const SizedBox(
                  height: 50,
                ),
                //welcome message
                const Text('Account Details'),
                const SizedBox(
                  height: 25,
                ),

                const SizedBox(
                  height: 25,
                ),

                const SizedBox(
                  height: 10,
                ),

                //sign out button
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
                    const SizedBox(
                      width: 25,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 25,
                ),
                //not a member? register now
              ],
            ),
          );
        },
      ),
    );
  }
}
