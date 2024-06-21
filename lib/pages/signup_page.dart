import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:provider/provider.dart';
import 'package:guide_solve/data/issue_data.dart';

class SignupPage extends StatefulWidget {
  SignupPage({super.key});

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
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            padding: const EdgeInsets.all(15),
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Sign Up'),]
        
            // SignInScreen(
            //   providers: [
            //     EmailAuthProvider(),
            //   ],
            //   actions: [
            //     AuthStateChangeAction<SignedIn>((context, state) {
            //       // Save IssueData to the user's account after sign-in
            //       User? user = FirebaseAuth.instance.currentUser;
            //       if (user != null) {
            //         // Assuming you have a method to save IssueData to the user's account
            //         issueData.saveToUserAccount(user);
            //       }
            //     }),
            //   ],
            // ),
          ),
        ),
      ),
    )
    )
    );
  }
}