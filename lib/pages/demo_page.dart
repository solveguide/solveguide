import 'package:flutter/material.dart';
import 'package:guide_solve/components/blue_container.dart';
import 'package:guide_solve/data/issue_data.dart';
import 'package:guide_solve/pages/solutions_page.dart';
import 'package:provider/provider.dart';

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
      if (issueData.numberOfHypothesesInIssue(widget.demoIssue) < 2) {
        createNewHypothesis(); // This should show the AlertDialog.
      }
    });
  }


  // create a new hypothesis for this issue
  void createNewHypothesis() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: const Text("Possible Root Theory:"),
          content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              const Text('Widen your thinking to come up with possible root causes. Try Exercises like 5 Why\'s or Negative Brainstorming. Do not judge quality or likelihood at this point.'),
              const SizedBox(height: 20), // Adds spacing
              TextFormField(
                controller: newHypothesisDescController,
                focusNode: _focusNode,
                autofocus: true,
                //textInputAction: TextInputAction.done,
                onFieldSubmitted: (value) => save(), // Assuming 'save' is defined
                decoration: const InputDecoration(
                  hintText: "Possible root theory",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
          actions: [
            //save button
            MaterialButton(
              onPressed: save,
              child: const Text("Add"),
            ),

            //cancel button
            MaterialButton(
              onPressed: cancel,
              child: const Text("Done"),
            ),
          ]),
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
  void clear(){
    newHypothesisDescController.clear();
  }

  //Confirm Issue-Root Relationship
  void confirmRootTheory(String chosenHypothesis) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: const Text("Confirm Root Theory"),
          content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              const SizedBox(height: 20), // Adds spacing
              Text('$chosenHypothesis is the root issue underlying: ${widget.demoIssue}'),
            ],
          ),
        ),
          actions: [
            //save button
            MaterialButton(
              onPressed: () => goToSolutionsPage(widget.demoIssue, chosenHypothesis),
              child: const Text("Confirm"),
            ),

            //cancel button
            MaterialButton(
              onPressed: cancel,
              child: const Text("Go Back"),
            ),
          ]),
    );
  }

  //goToSolutionsPage
  void goToSolutionsPage(String issue, String theory){
    Provider.of<IssueData>(context, listen: false).setRoot(issue, theory);
    Navigator.push(context, MaterialPageRoute(builder: (context) => SolutionsPage(demoIssue: issue, rootTheoryDesc:  theory),));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<IssueData>(
      builder: (context, value, child) => Scaffold(
        backgroundColor: Colors.orange[50],
        appBar: AppBar(
          backgroundColor: Colors.orange[50],
          title: const Text('Identify the Issue'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: createNewHypothesis,
          backgroundColor: Colors.red,
          tooltip: 'Widen root issues',
          child: const Icon(Icons.add),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              buildBlueContainer('Current Issue', widget.demoIssue),
              Expanded(
                    child: ReorderableListView.builder(
                      itemCount: value.numberOfHypothesesInIssue(widget.demoIssue),
                      itemBuilder: (context, index) => Card(
                        key: ValueKey(value.getRelevantIssue(widget.demoIssue).hypotheses[index]),
                        elevation: 2.0, // Adds a shadow
                        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0), // Margin around each card
                        child: ListTile(
                          title: Text(value.getRelevantIssue(widget.demoIssue).hypotheses[index].desc),
                          onTap: () => confirmRootTheory(value.getHypothesisList(widget.demoIssue)[index].desc),
                        ),
                      ),
                        onReorder: (int oldIndex, int newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) {
                            newIndex -= 1;
                          }
                          final item = value.getRelevantIssue(widget.demoIssue).hypotheses.removeAt(oldIndex);
                          value.getRelevantIssue(widget.demoIssue).hypotheses.insert(newIndex, item);
                        });
                      },
                        proxyDecorator: (Widget child, int index, Animation<double> animation) {
                        // Return the child directly without any additional decoration
                        return child;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
  }
}
