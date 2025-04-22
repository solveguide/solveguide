import 'package:flutter/material.dart';
import 'package:guide_solve/bloc/auth/auth_bloc.dart';

class MagicLoginViewModel with ChangeNotifier {
  final AuthBloc authBloc;

  final emailController = TextEditingController();
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<String?> message = ValueNotifier(null);

  MagicLoginViewModel(this.authBloc) {
    authBloc.stream.listen((state) {
      if (state is AuthLoading) {
        isLoading.value = true;
      } else {
        isLoading.value = false;
      }

      if (state is AuthWaitingOnMagicLinkClick) {
        message.value = 'Magic link sent! Check your email inbox.';
      } else if (state is AuthMagicLinkNeedsEmail) {
        message.value = 'Please enter your email to verify the magic link.';
      } else if (state is AuthFailure) {
        message.value = state.error;
      } else if (state is AuthSuccess) {
        message.value = 'Login successful! Redirecting...';
        onAuthSuccess?.call();
      } else {
        message.value = null;
      }
    });
  }

// Callback for navigation
  Function? onAuthSuccess;

  // Send magic link
  void sendMagicLink() {
    final email = emailController.text.trim().toLowerCase();
    if (email.isEmpty) {
      message.value = 'Please enter a valid email.';
      return;
    }
    authBloc.add(AuthMagicLinkRequested(email: email));
  }

  // Verify magic link with email confirmation
  void verifyMagicLinkWithEmail(String magicLink) {
    final email = emailController.text.trim().toLowerCase();
    if (email.isEmpty) {
      message.value = 'Please enter your email to verify the link.';
      return;
    }
    authBloc.add(
        AuthMagicLinkVerifiedWithEmail(magicLink: magicLink, email: email));
  }

  @override
  void dispose() {
    emailController.dispose();
    isLoading.dispose();
    message.dispose();
    super.dispose();
  }
}
