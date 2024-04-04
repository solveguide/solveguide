import 'package:flutter/material.dart';
import 'package:guide_solve/components/blue_container.dart';
import 'package:guide_solve/data/issue_data.dart';
import 'package:guide_solve/pages/signup_page.dart';
import 'package:provider/provider.dart';

class SolvePage extends StatefulWidget {
  final String demoIssue;
  final String solve;
  const SolvePage({super.key, required this.demoIssue, required this.solve});

  @override
  State<SolvePage> createState() => _SolvePageState();
}

class _SolvePageState extends State<SolvePage> {
//build solve statement
String getSolveStatement(String issueLabel){
  String solveStatement = 'Something went wrong';
  solveStatement = Provider.of<IssueData>(context, listen: false).buildSolveStatement(issueLabel);
  return solveStatement;
}

// start the demo
  void goToSignupPage() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SignupPage(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<IssueData>(
      builder: (context, value, child) => Scaffold(
        backgroundColor: Colors.orange[50],
        appBar: AppBar(
          backgroundColor: Colors.orange[50],
          title: const Text('Take Action!'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              buildBlueContainer('Your Solve:', getSolveStatement(widget.demoIssue)),
              const SizedBox(height:20),
              const Text("Do you like what you see? Create an Account to save this solve and more."),
              Padding(
              padding: const EdgeInsets.all(8.0),
              child: MaterialButton(
                onPressed: () => goToSignupPage(),
                color: Colors.red,
                child: const Text("Create an Account"),
              ),
            )
            ],
                ),
              ),
      ),
      );
  }
}