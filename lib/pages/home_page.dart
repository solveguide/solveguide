// ignore_for_file: prefer_const_constructors,
//  prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:guide_solve/components/logo.dart';
import 'package:guide_solve/components/narrow_wide.dart';
import 'package:guide_solve/pages/login_page.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final demoIssueLabel = TextEditingController();
  bool isButtonEnabled = false; // Tracks whether demo button can be clicked

  @override
  void initState() {
    super.initState();
    // Add listener to text controller to enable button when text is entered
    demoIssueLabel.addListener(() {
      final isTextEntered = demoIssueLabel.text.isNotEmpty;
      setState(() {
        isButtonEnabled = isTextEntered;
      });
    });
  }

  Future<void> ensureAnonymousLogin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
  }

// go to signup page
  void goToLoginPage() {
    Navigator.push(
      context,
      MaterialPageRoute<Widget>(builder: (context) => LoginPage()),
    );
  }

  //UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        backgroundColor: Colors.orange[50],
        title: Text('Home'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: ListView(
          children: [
            _buildMainContainer(),
            SizedBox(height: 10),
            _buildCenterContainer(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContainer() {
    return Align(
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(maxWidth: 1000),
        decoration:
            _containerDecoration(Colors.lightBlue[200] ?? Colors.orange),
        padding: EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            logoTitle(30),
            SizedBox(height: 30),
            Container(
              constraints: BoxConstraints(maxWidth: 500),
              child: _buildDetailedText(),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: MaterialButton(
                onPressed: goToLoginPage,
                color: Colors.red,
                child: Text(
                  'Login',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterContainer() {
    return Center(
      child: Container(
        width: 500,
        decoration: _containerDecoration(Colors.white),
        padding: EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildHeaderText('Try Solve Guide'),
            SizedBox(height: 10),
            narrowInstructionText('Narrow in on a single issue.'),
            SizedBox(height: 6),
            Text(
              'Try using a recent example of a personal experience '
              "you'd like to avoid in the future.",
              textAlign: TextAlign.center,
              softWrap: true,
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(height: 10),
            TextField(
              controller: demoIssueLabel,
              onSubmitted: (String value) {},
              // keyboardType: TextInputType.multiline, // Enables line breaks
              //maxLines: null,
              decoration: InputDecoration(
                hintText: 'I feel concerned/hurt when... ',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: MaterialButton(
                onPressed: isButtonEnabled ? () => {} : null,
                color: Colors.red,
                disabledColor: Colors.grey,
                child: Text(
                  'Start!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _containerDecoration(Color color) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(width: 5),
    );
  }

  Widget _buildDetailedText() => Column(
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black), // Default text style
              children: const <TextSpan>[
                TextSpan(
                  text:
                      'Your issues persist because solving them requires you '
                      'to alternate between two different modes of thinking, '
                      'often in coordination with others.\n\n',
                ),
                TextSpan(
                  text:
                      'Getting out of sync while solving issues together can '
                      'lead to offending or misleading your peers without you '
                      'even noticing. ',
                ),
                TextSpan(
                  text: 'Small miscommunications lead to big issues!\n\n',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      'Solve Guide coordinates group issue solving. For now '
                      'you can create an account and solve issues solo. '
                      'Multiplayer mode is coming!\n\n',
                ),
                TextSpan(text: 'The two modes of thinking are:\n'),
              ],
            ),
          ),
          widenInstructionText(
            'Widening',
            text:
                'is creative; imagine all the possibilities without judgement.',
          ),
          SizedBox(height: 8),
          narrowInstructionText(
            'Narrowing',
            text: 'is critical; choose the best available path forward.',
          ),
          RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black), // Default text style
              children: const <TextSpan>[
                TextSpan(
                  text:
                      '\nYou will solve more issues for good if you can '
                      'observe reality creatively, '
                      'and navigate it critically.\n\n',
                ),
              ],
            ),
          ),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(color: Colors.black), // Default text style
              children: <TextSpan>[
                TextSpan(
                  text: 'Visit about.solve.guide to learn more.\n',
                  style: TextStyle(
                    color: Colors.blue.shade900,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launchUrl(Uri.parse('https://about.solve.guide'));
                    },
                ),
              ],
            ),
          ),
        ],
      );

  Widget _buildHeaderText(String text) => Text(
        text,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      );
}
