import 'package:flutter/material.dart';
import 'package:guide_solve/bloc/auth/auth_bloc.dart';

class LoginViewModel with ChangeNotifier {
  final AuthBloc authBloc;

  // Text Editing Controllers for email and password
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  LoginViewModel(this.authBloc);

  // Trigger login event
  void loginNow() {
    authBloc.add(
      AuthLoginRequested(
        email: emailController.text.trim().toLowerCase(),
        password: passwordController.text.trim(),
      ),
    );
  }

  // Trigger register event
  void registerNow() {
    authBloc.add(
      AuthRegisterRequested(
        email: emailController.text.trim().toLowerCase(),
        password: passwordController.text.trim(),
      ),
    );
  }

  // Clean up controllers
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
