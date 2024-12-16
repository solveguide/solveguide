import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/bloc/auth/auth_bloc.dart';
import 'package:guide_solve/pages/dashboard_page.dart';
import 'package:guide_solve/src/auth/view/login_view_model.dart';
import 'package:guide_solve/src/components/logo.dart';
import 'package:guide_solve/src/components/plain_button.dart';
import 'package:guide_solve/src/components/plain_textfield.dart';

class LoginView extends StatelessWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize the ViewModel with the AuthBloc
    final loginViewModel = LoginViewModel(BlocProvider.of<AuthBloc>(context));

    return AppScaffold(
      releaseFocus: true,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(),
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
              MaterialPageRoute<Widget>(
                builder: (context) => const DashboardPage(),
              ),
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Center(
            child: Column(
              children: [
                // Logo
                logoTitle(10),
                const SizedBox(height: 50),

                // Welcome message
                const Text('Welcome back!'),
                const SizedBox(height: 25),

                // Email field
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: PlainTextField(
                    hintText: 'email',
                    controller: loginViewModel.emailController,
                    obscureText: false,
                  ),
                ),
                const SizedBox(height: 25),

                // Password field
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: PlainTextField(
                    hintText: 'password',
                    controller: loginViewModel.passwordController,
                    obscureText: true,
                    onSubmit: loginViewModel.loginNow,
                  ),
                ),
                const SizedBox(height: 10),

                // Forgot password text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),

                // Sign-in and Register buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PlainButton(
                      onPressed: loginViewModel.loginNow,
                      text: 'Sign In',
                    ),
                    const SizedBox(width: 25),
                    PlainButton(
                      onPressed: loginViewModel.registerNow,
                      text: 'Register',
                    ),
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
