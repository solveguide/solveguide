// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:guide_solve/components/narrow_wide.dart';
import 'package:guide_solve/data/issue_data.dart';
import 'package:guide_solve/pages/demo_page.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final demoIssueLabel = TextEditingController();
  bool isButtonEnabled = false; // Tracks whether the start button should be enabled

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

// start the demo
  void goToDemo(String demoIssueLabel) {
    createDemoIssue(demoIssueLabel);
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DemoPage(demoIssue: demoIssueLabel),
        ));
  }

  // create the demo issue
  void createDemoIssue(String demoIssueLabel) {
    Provider.of<IssueData>(context, listen: false)
        .addIssue(demoIssueLabel);
  }

  //UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        backgroundColor: Colors.orange[50],
        title: Text("Home"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView(
          children: [
            _buildMainContainer(),
            SizedBox(height: 10), // Adjusted for clarity
            _buildCenterContainer(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContainer() {
    return Container(
      constraints: BoxConstraints(maxWidth: 1000),
      decoration: _containerDecoration(Colors.lightBlue[200] ?? Colors.orange),
      padding: EdgeInsets.all(25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _buildIconRow(),
          SizedBox(height: 30),
          _buildMainText(),
          SizedBox(height: 30),
          _buildDetailedText(),
        ],
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
            SizedBox(height:10),
            narrowInstructionText('Describe an issue.'),
            SizedBox(height:6),
            Text('Try using a real example of a recent, personal experience.', softWrap: true,),
           // _buildNormalText(
          //      'Start by narrowing in on a single, specific issue you are experiencing:'),
            SizedBox(height:10),
            TextField(
              controller: demoIssueLabel,
              onSubmitted: (String value)  {goToDemo(value);},
             // keyboardType: TextInputType.multiline, // Enables line breaks
              //maxLines: null,
              decoration: InputDecoration(
                hintText: "Your Issue Here.",
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 2.0),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: MaterialButton(
                onPressed: isButtonEnabled ? () => goToDemo(demoIssueLabel.text) : null,
                color: Colors.red,
                disabledColor: Colors.grey,
                child: Text("Start!", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
           // _buildFooterText(),
          ],
        ),
      ),
    );
  }

  BoxDecoration _containerDecoration(Color color) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(width: 5, color: Colors.black),
    );
  }

  Widget _buildIconRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Transform(
          transform: Matrix4.rotationY(pi),
          alignment: Alignment.center,
          child: Icon(Icons.psychology_outlined, size: 75),
        ),
        Icon(Icons.psychology_alt, size: 75),
      ],
    );
  }

  Widget _buildMainText() => const Text(
        'Solve Guide',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      );

  Widget _buildDetailedText() => Column(
    children: [
      RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black), // Default text style
              children: <TextSpan>[
                TextSpan(text: 'Solving issues is difficult because it requires you to switch between two very different modes of thinking.\n\n'),
              ],
            ),
          ),
          narrowInstructionText('Narrowing', text:'is critical; choosing the best available path forward.'),
          SizedBox(height: 8),
          widenInstructionText('Widening', text:'is creative; imagining possibilities without judgement.'),
          RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black), // Default text style
              children: <TextSpan>[
                TextSpan(text: '\n\nThe best outcomes arise when you can be creative towards observing reality, and critical towards your plan to navigate it. Solve Guide is intended to help you achieve that balance.\n'),
              ],
            ),
          ),
        RichText(
          textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(color: Colors.black), // Default text style
              children: <TextSpan>[
                TextSpan(
                  text: 'Visit about.solve.guide to learn more.',
                  style: TextStyle(color: Colors.blueGrey, decoration: TextDecoration.underline, fontSize: 10),
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

  Widget _buildNormalText(String text) => Text(
        text,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
      );

/*  Widget _buildFooterText() => Text(
        '- Keep it simple. We will break it down next.\n'
        '- Try to describe the issue in terms of your negative experience; do not include the absent solution.\n',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.normal),
      );
*/
}
