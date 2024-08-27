import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/bloc/auth/auth_bloc.dart';
import 'package:guide_solve/components/logo.dart';
import 'package:guide_solve/components/plain_button.dart';
import 'package:guide_solve/components/plain_textfield.dart';
import 'package:guide_solve/pages/dashboard_page.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  //controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  

  @override
  Widget build(BuildContext context) {

    loginNow() {
  BlocProvider.of<AuthBloc>(context, listen: false).add(
    AuthLoginRequested(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    ),
  );
}

    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        backgroundColor: Colors.orange[50],
        title: const Text('Login/Register'),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
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
                  onSubmit: loginNow,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PlainButton(
                      onPressed: () {
                        BlocProvider.of<AuthBloc>(context, listen: false).add(
                          AuthLoginRequested(
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                          ),
                        );
                      },
                      text: "Sign In",
                    ),
                    const SizedBox(
                      width: 25.0,
                    ),
                    PlainButton(
                      onPressed: () {
                        BlocProvider.of<AuthBloc>(context, listen: false).add(
                          AuthRegisterRequested(
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                          ),
                        );
                      },
                      text: "Register",
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
