import 'package:flutter/material.dart';
import 'package:guide_solve/components/blue_container.dart';
import 'package:guide_solve/data/issue_data.dart';
import 'package:guide_solve/pages/solutions_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

class DemoPage extends StatefulWidget {
  final String demoIssue;
  const DemoPage({super.key, required this.demoIssue});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

//UI
class _DemoPageState extends State<DemoPage> {
  //text controller
  final newHypothesisDescController = TextEditingController();
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
      if (issueData.numberOfHypothesesInIssue(widget.demoIssue) < 1) {
        showInstructionsDialog(context); // This should show the AlertDialog.
      }
    });
  }

  void showInstructionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("How to Pick a Root Issue"),
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
                              "The first step in solving your issue is to identify the most impactful root cause that you can influence. Here’s the steps you will follow: \n\n"),
                      TextSpan(
                          text: "1. ",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                          text:
                              "Widen your thinking by entering as many potential root causes as possible. Do not judge quality or likelihood at this point, just widen!\n"),
                      TextSpan(
                          text: "2. ",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                          text:
                              "Drag to re-order your potential root causes with the most impactful, likely and changeable ones towards the top.\n"),
                      TextSpan(
                          text: "3. ",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                          text:
                              "Click on the top root cause to test it against your original issue.\n"),
                      TextSpan(
                          text: "4. ",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                          text:
                              "If it makes sense, accept the root cause and get ready to narrow again.\n\n"),
                      TextSpan(
                          text: "Issues you may encounter:\n",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, height: 2)),
                      TextSpan(
                          text:
                              "- If your issue doesn’t seem to have a root, go back and make your issue more specific. To have the best shot at solving an issue, you want to start by narrowing. Try picking a specific example of the issue you originally entered.\n"),
                      TextSpan(
                          text:
                              "- If you are having trouble coming up with possible root causes, "),
                      TextSpan(
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue),
                        text:
                            "try exercises like “5 Whys” or “Reverse Brainstorming”",
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrl(Uri.parse('https://about.solve.guide'),
                                mode: LaunchMode.externalApplication);
                          },
                      ),
                      TextSpan(text: ".\n"),
                      TextSpan(
                          text:
                              "- If you are having trouble picking the right root to move forward with, "),
                      TextSpan(
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue),
                        text:
                            "focus on the root causes you have the most influence over",
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

  //save Hypothesis
  void save() {
    String newHypothesisDesc = newHypothesisDescController.text;
    Provider.of<IssueData>(context, listen: false)
        .addHypothesis(widget.demoIssue, newHypothesisDesc);
    clear();
    _focusNode.requestFocus();
  }

  //cancel Hypothesis
  void cancel() {
    Navigator.pop(context);
  }

  //clear controllers
  void clear() {
    newHypothesisDescController.clear();
  }

  //Confirm Issue-Root Relationship
  void confirmRootTheory(String chosenHypothesis) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: const Text("Confirm Root"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const SizedBox(height: 20), // Adds spacing
                Text(
                    '$chosenHypothesis \n\n is causing:\n\n ${widget.demoIssue}'),
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
              onPressed: () =>
                  goToSolutionsPage(widget.demoIssue, chosenHypothesis),
              child: const Text("Confirm"),
            ),
          ]),
    );
  }

  //goToSolutionsPage
  void goToSolutionsPage(String issue, String theory) {
    Navigator.pop(context);
    Provider.of<IssueData>(context, listen: false).setRoot(issue, theory);
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SolutionsPage(demoIssue: issue, root: theory),
        ));
  }

  //edit hypothesis item
void editItem(int index, String hypothesisDesc) {
  // Set text in TextEditingController to the hypothesis description
  newHypothesisDescController.text = hypothesisDesc;

  // Remove the hypothesis from the list in your data model
  Provider.of<IssueData>(context, listen: false).removeHypothesis(widget.demoIssue, index);

  // Request focus for the text input field
  FocusScope.of(context).requestFocus(_focusNode);

  // Optional: You might want to handle state update here if needed
  setState(() {});
}


  @override
  Widget build(BuildContext context) {
    return Consumer<IssueData>(
      builder: (context, value, child) => Scaffold(
        backgroundColor: Colors.orange[50],
        appBar: AppBar(
          backgroundColor: Colors.orange[50],
          title: const Text('Get to the Root'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 1000),
              child: Column(
                children: [
                  buildBlueContainer('Current Issue', widget.demoIssue),
                  SizedBox(height: 5),
                  TextFormField(
                    controller: newHypothesisDescController,
                    focusNode: _focusNode,
                    autofocus: true,
                    //textInputAction: TextInputAction.done,
                    onFieldSubmitted: (value) =>
                        save(), // Assuming 'save' is defined
                    decoration: const InputDecoration(
                      hintText: "Enter root theories here.",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  Expanded(
                    child: ReorderableListView.builder(
                      itemCount:
                          value.numberOfHypothesesInIssue(widget.demoIssue),
                      itemBuilder: (context, index) => Card(
                        key: ValueKey(value
                            .getRelevantIssue(widget.demoIssue)
                            .hypotheses[index]),
                        elevation: 2.0, // Adds a shadow
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 5.0), // Margin around each card
                        child: ListTile(
                          leading: IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              editItem(index, value.getHypothesisList(widget.demoIssue)[index].desc); // Replace 'editFunction' with the actual function you want to call
                            },
                          ),
                          title: Text(value
                              .getRelevantIssue(widget.demoIssue)
                              .hypotheses[index]
                              .desc),
                          onTap: () => confirmRootTheory(value
                              .getHypothesisList(widget.demoIssue)[index]
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
                              .hypotheses
                              .removeAt(oldIndex);
                          value
                              .getRelevantIssue(widget.demoIssue)
                              .hypotheses
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
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showInstructionsDialog(context),
          backgroundColor: Colors.lightBlue[200],
          child: Icon(Icons.help_outline),
        ),
      ),
    );
  }
}
