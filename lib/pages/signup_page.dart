import 'package:flutter/material.dart';
import 'package:guide_solve/components/blue_container.dart';
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
              buildBlueContainer('Sorry', 'This page isn\'t ready yet'),
              Center(
                child: Container(
                  width: 500,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(width: 5, color: Theme.of(context).colorScheme.onBackground),
                  ),
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,

                    //welcome back message

                    //email text field
                    children: [
                      PlainTextField(
                        hintText: "email",
                        controller: _emailController,
                        )
                        ],

                    //send link button
                  ),
                ),
              ),
            ]
          )
        )
      )
    );
  }
}
