import 'package:flutter/material.dart';
//import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:provider/provider.dart';
import 'package:guide_solve/data/issue_data.dart';

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
                child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Sign Up'),
                    ]),
              ),
            )));
  }
}
