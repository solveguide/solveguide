// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:guide_solve/data/issue_data.dart';
import 'package:guide_solve/pages/demo_page.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final demoIssueLabel = TextEditingController();

// start the demo
  void goToDemo(String demoIssueLabel) {
    createDemoIssue();
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DemoPage(demoIssue: demoIssueLabel),
        ));
  }

  // create the demo issue
  void createDemoIssue() {
    Provider.of<IssueData>(context, listen: false)
        .addIssue(demoIssueLabel.text);
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
          SizedBox(height: 50),
          _buildMainText(),
          SizedBox(height: 50),
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
            _buildHeaderText('Solve an Issue'),
            SizedBox(height:10),
            _buildNormalText(
                'Describe an Issue, Problem or Conflict you are facing in one sentence.'),
            TextField(
              controller: demoIssueLabel,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: MaterialButton(
                onPressed: () => goToDemo(demoIssueLabel.text),
                color: Colors.red,
                child: Text("Solve it!"),
              ),
            ),
            _buildFooterText(),
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
        'Resolve conflicts faster, for good',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      );

  Widget _buildDetailedText() => const Text(
        'Are you tired of rehashing the same issues with the people in your life? \n\nDo you feel like you get caught in the least important aspects of a conflict while the obvious root of the issue goes ignored and unresolved? \n\nDo you feel like shared facts keep slipping into contested territory, causing debates to go in circles? \n\nSolveGuide is a friendly tool that will guide you to solutions that last. You can use SolveGuide alone or with others to make progress on issues in your relationship, in the workplace or anywhere else you are struggling.\n\n',
      );

  Widget _buildHeaderText(String text) => Text(
        text,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      );

  Widget _buildNormalText(String text) => Text(
        text,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
      );

  Widget _buildFooterText() => Text(
        '- Keep it simple. We will break it down next.\n'
        '- Try to describe the issue as a negative experience, not as the absent solution.\n'
        '- Be as factual as possible, but remember that observations, emotional experiences, thoughts\n',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.normal),
      );
}
