import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/bloc/auth_bloc.dart';
import 'package:guide_solve/components/logo.dart';
import 'package:guide_solve/components/plain_button.dart';
import 'package:guide_solve/components/plain_textfield.dart';
import 'package:guide_solve/pages/dashboard_page.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  //controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  //signin function
  void requestSignIn() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        backgroundColor: Colors.orange[50],
        title: const Text('Your Account'),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
              ),
            );
          }

          if (state is AuthSuccess) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const DashboardPage(),
                ),
                (route) => false);
          }
        },
        child: Center(
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthLoading) {
                return const CircularProgressIndicator();
              }
              return Column(
                children: [
                  //logo
                  logoTitle(10),
                  const SizedBox(
                    height: 50,
                  ),
                  //welcome message
                  const Text("Welcome back!"),
                  const SizedBox(
                    height: 25,
                  ),

                  // username text field
                  PlainTextField(
                    hintText: "email",
                    controller: emailController,
                    obscureText: false,
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  // password text field
                  PlainTextField(
                    hintText: "password",
                    controller: passwordController,
                    obscureText: true,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        )
                      ],
                    ),
                  ),
                  //sign in button
                  PlainButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(
                            AuthLoginRequested(
                              email: emailController.text.trim(),
                              password: passwordController.text.trim(),
                            ),
                          );
                    },
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  //not a member? register now
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
