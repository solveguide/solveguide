// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        backgroundColor: Colors.orange[50],
        title: Text("Home"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Center(
              child: Container(
                width: 500,
                decoration: BoxDecoration(
                  color: Colors.lightBlue[200],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(width: 5, color: Colors.black),
                ),
                padding: EdgeInsets.all(25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset('images/SolveGuideLogoSmall.jpg',
                        width: 200, fit: BoxFit.scaleDown),
                    const SizedBox(
                        height: 75), // Adds space between image and text
                    const Text(
                      'Resolve conflicts faster, for good',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                        height: 50), // Adds space between image and text
                    const Text(
                        'Are you tired of rehashing the same issues with the people in your life?\n\n'
                        'Do you feel like you get caught in the least important aspects of a conflict while the obvious root of the issue goes ignored and unresolved?\n\n'
                        'Do you feel like shared facts keep slipping into contested territory, causing debates to go in circles?\n\n'
                        'SolveGuide is a friendly tool that will guide you to solutions that last. You can use SolveGuide alone or with others to make progress on issues in your relationship, in the workplace or anywhere else you are struggling.\n\n'),
                    const Text(
                      'You have this many issues:',
                    ),
                    Text(
                      "99",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: Container(
                width: 500,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(width: 5, color: Colors.black),
                ),
                padding: EdgeInsets.all(25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      'Solve an Issue',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Describe an Issue, Problem or Conflict you are facing in one sentence.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    TextField(),
                    Container(
                      color: Colors.red,
                      height: 30,
                      width: 100,
                    ),
                    Text(
                      '- Keep it simple. We will break it down next.\n'
                      '- Try to describe the issue as a negative experience, not as the absent solution.\n'
                      '- Be as factual as possible, but remember that observations, emotional experiences, thoughts\n',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.normal,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
