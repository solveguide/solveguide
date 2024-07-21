import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as firebase_ui_auth;
import 'package:provider/provider.dart';
import 'package:guide_solve/data/issue_data.dart';
//import 'package:guide_solve/pages/dashboard_page.dart';

class SolvePage extends StatefulWidget {
  final String demoIssue;
  final String root;
  final String solve;
  const SolvePage({
    super.key,
    required this.demoIssue,
    required this.root,
    required this.solve,
  });

  @override
  State<SolvePage> createState() => _SolvePageState();
}

class _SolvePageState extends State<SolvePage> {
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null && !user.isAnonymous) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    });
  }

  // Go to signup page
  void goToSignupPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => firebase_ui_auth.RegisterScreen(
          providers: [
            firebase_ui_auth.EmailAuthProvider(),
          ],
          actions: [
            firebase_ui_auth.AuthStateChangeAction<firebase_ui_auth.SignedIn>(
              (context, state) {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/dashboard');
              },
            ),
          ],
          subtitleBuilder: (context, action) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: action == firebase_ui_auth.AuthAction.signIn
                  ? const Text('Sign in with the credentials you just created.')
                  : const Text(
                      'Once you\'ve clicked register once, click the sign-in link and use the credentials you just created.'),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<IssueData>(
      builder: (context, issueData, child) => Scaffold(
        backgroundColor: Colors.orange[50],
        appBar: AppBar(
          backgroundColor: Colors.orange[50],
          title: const Text('Take Action!'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: ListView(
            children: [
              buildSummaryContainer(context),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300] ?? Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(width: 5, color: Colors.black),
                  ),
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                "Root Theories Considered:",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: issueData
                                    .getHypothesisList(widget.demoIssue)
                                    .map((item) => ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          title: Text(item.desc),
                                        ))
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                "Solutions Considered:",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: issueData
                                    .getSolutionList(widget.demoIssue)
                                    .map((item) => ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          title: Text(item.desc),
                                        ))
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Do you like what you see? Create an Account to save this solve and more.",
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MaterialButton(
                  onPressed: goToSignupPage,
                  color: Colors.red,
                  child: const Text("Create an Account"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSummaryContainer(BuildContext context) {
    return Center(
      child: Container(
        width: 500,
        decoration: BoxDecoration(
          color: Colors.lightBlue[200] ?? Colors.orange,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(width: 5, color: Colors.black),
        ),
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Your Solve:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  const TextSpan(
                    text: 'I will: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: '${widget.solve}.',
                    style: const TextStyle(fontWeight: FontWeight.normal),
                  ),
                  const TextSpan(
                    text: '\n\nResolving that: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: '${widget.root}.',
                    style: const TextStyle(fontWeight: FontWeight.normal),
                  ),
                  const TextSpan(
                    text: '\n\nChanging that: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: widget.demoIssue,
                    style: const TextStyle(fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
