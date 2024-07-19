//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as firebase_ui_auth;
import 'package:provider/provider.dart';
import 'package:guide_solve/data/issue_data.dart';
import 'package:guide_solve/pages/dashboard_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<IssueData>(
      builder: (context, issueData, child) => Scaffold(
        backgroundColor: Colors.orange[50],
        appBar: AppBar(
          backgroundColor: Colors.orange[50],
          title: const Text('Your Account'),
        ),
        body: Center(
          child: Container(
            width: 500,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                width: 5,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Sign up to solve multiple issues and track your progress',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),
                firebase_ui_auth.SignInScreen(
                  providers: [
                    firebase_ui_auth.EmailAuthProvider(),
                  ],
                  actions: [
                    firebase_ui_auth.AuthStateChangeAction<
                        firebase_ui_auth.SignedIn>(
                      (context, state) async {
                        final issueData =
                            Provider.of<IssueData>(context, listen: false);
                        // Save the demo issue if it exists
                        await issueData.saveDemoIssue();

                        if (context.mounted) {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const DashboardPage()),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
