import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:guide_solve/components/plain_textfield.dart';
import 'package:guide_solve/data/issue_data.dart';
import 'package:provider/provider.dart';

class SignupPage extends StatefulWidget {
  SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _emailController = TextEditingController();
    final FirebaseAuth _auth = FirebaseAuth.instance;

   Future<void> _sendMagicLink() async {
    final email = _emailController.text.trim();
    if (email.isNotEmpty) {
      await _auth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: ActionCodeSettings(
          url: 'https://solve.guide',
          handleCodeInApp: true,
          androidPackageName: 'com.example.android',
          androidInstallApp: true,
          androidMinimumVersion: '12',
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Magic link sent to $email')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<IssueData>(
        builder: (context, value, child) => Scaffold(
            backgroundColor: Colors.orange[50],
            appBar: AppBar(
              backgroundColor: Colors.orange[50],
              title: const Text('Your Account'),
            ),
            body: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Container(
                          width: 500,
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.tertiaryContainer,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                width: 5,
                                color:
                                    Theme.of(context).colorScheme.onBackground),
                          ),
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              //welcome back message
                              Padding(
                                padding: const EdgeInsets.all(25.0),
                                child: Text("To login to your account enter your email and click the magic link that arrives in your inbox. \n\n If you are creating an account for the first time, follow the same process."),
                              ),

                              //email text field
                              PlainTextField(
                                hintText: "email",
                                controller: _emailController,
                              ),
                              //send link button
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: MaterialButton(
                                  onPressed: _sendMagicLink,
                                  color: Colors.red,
                                  disabledColor: Colors.grey,
                                  child: Text("Send Link to Email",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]))));
  }
}
