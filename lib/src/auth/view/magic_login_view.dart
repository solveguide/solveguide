import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:guide_solve/bloc/auth/auth_bloc.dart';
import 'package:guide_solve/src/auth/view/magic_login_view_model.dart';

import '../../app/routes/routes.dart';

class MagicLoginView extends StatelessWidget {
  const MagicLoginView({Key? key, this.magicLink}) : super(key: key);

  final String? magicLink;

  @override
  Widget build(BuildContext context) {
    final magicLoginViewModel =
        MagicLoginViewModel(BlocProvider.of<AuthBloc>(context));

    // Set the navigation callback
    magicLoginViewModel.onAuthSuccess = () {
      context.goNamed(AppRoutes.dashboard.name);
    };

    return AppScaffold(
      releaseFocus: true,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ValueListenableBuilder<String?>(
          valueListenable: magicLoginViewModel.message,
          builder: (context, message, child) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (message != null) ...[
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (magicLink == null) ...[
                    const Text(
                      'Enter your email to receive a magic link for login.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 600),
                      child: ShadInput(
                        placeholder: const Text('email'),
                        controller: magicLoginViewModel.emailController,
                        obscureText: false,
                        autofocus: true,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ShadButton(
                      onPressed: magicLoginViewModel.sendMagicLink,
                      child: const Text('Send Magic Link'),
                      icon: Icon(Icons.email),
                    ),
                  ] else ...[
                    const Text(
                      'Please enter your email to verify the magic link.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 600),
                      child: ShadInput(
                        placeholder: const Text('email'),
                        controller: magicLoginViewModel.emailController,
                        obscureText: false,
                        autofocus: true,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ShadButton(
                      onPressed: () => magicLoginViewModel
                          .verifyMagicLinkWithEmail(magicLink!),
                      child: const Text('Verify Email'),
                    ),
                  ],
                  ValueListenableBuilder<bool>(
                    valueListenable: magicLoginViewModel.isLoading,
                    builder: (context, isLoading, child) {
                      if (isLoading) {
                        return const CircularProgressIndicator();
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
