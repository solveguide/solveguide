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
          children: [
            Center(
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
                      height: 75), // Adds space between image and text
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
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
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
                      height: 75), // Adds space between image and text
                  const Text(
                      'Are you tired of rehashing the same issues with the people in your life?\n\n'
                      'Do you feel like you get caught in the least important aspects of a conflict while the obvious root of the issue goes ignored and unresolved?\n\n'
                      'Do you feel like shared facts keep slipping into contested territory, causing debates to go in circles?\n\n'
                      'SolveGuide is a friendly tool that will guide you to solutions that last. You can use SolveGuide alone or with others to make progress on issues in your relationship, in the workplace or anywhere else you are struggling.\n\n'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
