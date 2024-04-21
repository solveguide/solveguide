import 'package:flutter/material.dart';
import 'package:guide_solve/components/blue_container.dart';
import 'package:guide_solve/data/issue_data.dart';
import 'package:guide_solve/pages/solve_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

class SolutionsPage extends StatefulWidget {
  final String demoIssue;
  final String root;
  const SolutionsPage(
      {super.key, required this.demoIssue, required this.root});

  @override
  State<SolutionsPage> createState() => _SolutionsPageState();
}

class _SolutionsPageState extends State<SolutionsPage> {
  //text controller
  final newSolutionNameController = TextEditingController();
  //focus node
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Access your condition here using your context-dependent logic.
      // For example:
      final issueData = Provider.of<IssueData>(context, listen: false);
      if (issueData.numberOfSolutionsInIssue(widget.demoIssue) < 1) {
        showInstructionsDialog(context); // This should show the AlertDialog.
      }
    });
  }

  // Demo Instructions
  void showInstructionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("How to Pick a Solution"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16), // Default text style
                    children: <TextSpan>[
                      TextSpan(
                          text: 'Instructions\n',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, height: 2)),
                      TextSpan(
                          text:
                              "Now that you've narrowed on a single root cause, it's time to widen again. Here’s the steps you will follow: \n\n"),
                      TextSpan(
                          text: "1. ",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                          text:
                              "Widen your thinking by entering as many ways as you can imagine to make your root issue go away. Don't worry about quality, just widen!\n"),
                      TextSpan(
                          text: "2. ",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                          text:
                              "Drag to re-order your solutions with the most effective, easiest and fastest ones at the top.\n"),
                      TextSpan(
                          text: "3. ",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                          text:
                              "Click on the top solution to test it against your root issue.\n"),
                      TextSpan(
                          text: "4. ",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                          text:
                              "If it makes sense, accept the solution and get ready to take action!\n\n"),
                      TextSpan(
                          text: "Issues you may encounter:\n",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, height: 2)),
                      TextSpan(
                          text:
                              "- If your root issue doesn't seem to have any solutions than you may have picked a root that you are not able to influence. Go back and pick a root cause you can affect.\n"),
                      TextSpan(
                          text:
                              "- If you are having trouble coming up with possible solutions, "),
                      TextSpan(
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue),
                        text:
                            "try analogizing your root issue into different domains, or ask friends, experts, or forums. Remember you aren't judging quality yet, just widening your thinking.",
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrl(Uri.parse('https://about.solve.guide'),
                                mode: LaunchMode.externalApplication);
                          },
                      ),
                      TextSpan(text: ".\n"),
                      TextSpan(
                          text:
                              "- If you are having trouble picking the right solution, "),
                      TextSpan(
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue),
                        text:
                            "focus on the level of confidence in the connection between solution and root, and your ability to quickly complete the solution.",
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrl(Uri.parse('https://about.solve.guide'),
                                mode: LaunchMode.externalApplication);
                          },
                      ),
                      TextSpan(text: ".\n"),
                    ],
                  ),
                )
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // add solution to list
  void save() {
    String newSolutionDesc = newSolutionNameController.text;
    Provider.of<IssueData>(context, listen: false)
        .addSolution(widget.demoIssue, newSolutionDesc);
    clear();
    _focusNode.requestFocus();
  }

  //stop adding Solutions
  void cancel() {
    Navigator.pop(context);
  }

  //clear controllers
  void clear() {
    newSolutionNameController.clear();
  }

  //Confirm Issue-Root Relationship
  void confirmChosenSolution(String chosenSolution) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: const Text("Confirm Chosen Solution"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const SizedBox(height: 20), // Adds spacing
                Text(
                    '$chosenSolution \n\n will resolve:\n\n ${Provider.of<IssueData>(context, listen: false).getRelevantIssue(widget.demoIssue).root}'),
              ],
            ),
          ),
          actions: [
            //cancel button
            MaterialButton(
              onPressed: cancel,
              child: const Text("Go Back"),
            ),

            //save button
            MaterialButton(
              onPressed: () => goToSolvePage(widget.demoIssue, widget.root, chosenSolution),
              child: const Text("Confirm"),
            ),
          ]),
    );
  }

  //goToSolvePage
  void goToSolvePage(String issue, String root, String solution) {
    Provider.of<IssueData>(context, listen: false).setSolve(issue, solution);
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SolvePage(demoIssue: issue, root: root, solve: solution),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<IssueData>(
        builder: (context, value, child) => Scaffold(
              backgroundColor: Colors.orange[50],
              appBar: AppBar(
                backgroundColor: Colors.orange[50],
                title: const Text('Select the Solution'),
              ),
              body: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    buildBlueContainer('Root Issue',
                        value.getRelevantIssue(widget.demoIssue).root),
                    SizedBox(height: 5),
                    TextFormField(
                      controller: newSolutionNameController,
                      focusNode: _focusNode,
                      autofocus: true,
                      onFieldSubmitted: (value) => save(),
                      decoration: const InputDecoration(
                        hintText: "Enter possible solutions here.",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    Expanded(
                      child: ReorderableListView.builder(
                        itemCount:
                            value.numberOfSolutionsInIssue(widget.demoIssue),
                        itemBuilder: (context, index) => Card(
                          key: ValueKey(value
                              .getRelevantIssue(widget.demoIssue)
                              .solutions[index]),
                          elevation: 2.0, // Adds a shadow
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 5.0), // Margin around each card
                          child: ListTile(
                            title: Text(value
                                .getRelevantIssue(widget.demoIssue)
                                .solutions[index]
                                .desc),
                            onTap: () => confirmChosenSolution(value
                                .getSolutionList(widget.demoIssue)[index]
                                .desc),
                          ),
                        ),
                        onReorder: (int oldIndex, int newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) {
                              newIndex -= 1;
                            }
                            final item = value
                                .getRelevantIssue(widget.demoIssue)
                                .solutions
                                .removeAt(oldIndex);
                            value
                                .getRelevantIssue(widget.demoIssue)
                                .solutions
                                .insert(newIndex, item);
                          });
                        },
                        proxyDecorator: (Widget child, int index,
                            Animation<double> animation) {
                          // Return the child directly without any additional decoration
                          return child;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () => showInstructionsDialog(context),
                backgroundColor:
                    Colors.lightBlue[200],
                    child: Icon(Icons.help_outline), 
              ),
            ));
  }
}
