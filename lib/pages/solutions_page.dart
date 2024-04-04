import 'package:flutter/material.dart';
import 'package:guide_solve/components/blue_container.dart';
import 'package:guide_solve/data/issue_data.dart';
import 'package:guide_solve/pages/solve_page.dart';
import 'package:provider/provider.dart';

class SolutionsPage extends StatefulWidget {
  final String demoIssue;
  final String rootTheoryDesc;
  const SolutionsPage({super.key, required this.demoIssue, required this.rootTheoryDesc});

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
      if (issueData.numberOfSolutionsInIssue(widget.demoIssue) < 2) {
        createNewSolution(); // This should show the AlertDialog.
      }
    });
  }

  // create a new solution for this issue
  void createNewSolution() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: const Text("Possible Solution:"),
          content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              const Text('Widen your thinking to come up with possible solutions.'),
              const SizedBox(height: 20), // Adds spacing
              TextFormField(
                controller: newSolutionNameController,
                focusNode: _focusNode,
                autofocus: true,
                //textInputAction: TextInputAction.done,
                onFieldSubmitted: (value) => save(), // Assuming 'save' is defined
                decoration: const InputDecoration(
                  hintText: "Enter possible solution here",
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
  void clear(){
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
              Text('$chosenSolution is the best way to address the fact that: ${Provider.of<IssueData>(context, listen: false).getRelevantIssue(widget.demoIssue).root}'),
            ],
          ),
        ),
          actions: [
            //save button
            MaterialButton(
              onPressed: () => goToSolvePage(widget.demoIssue, chosenSolution),
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

  //goToSolvePage
  void goToSolvePage(String issue, String solution){
    Provider.of<IssueData>(context, listen: false).setSolve(issue, solution);
    Navigator.push(context, MaterialPageRoute(builder: (context) => SolvePage(demoIssue: issue, solve:  solution),));
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
        floatingActionButton: FloatingActionButton(
          onPressed: createNewSolution,
          backgroundColor: Colors.red,
          tooltip: 'Add a possible solution',
          child: const Icon(Icons.add),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              buildBlueContainer('Root Issue', value.getRelevantIssue(widget.demoIssue).root),
              Expanded(
                    child: ReorderableListView.builder(
                      itemCount:
                          value.numberOfSolutionsInIssue(widget.demoIssue),
                      itemBuilder: (context, index) => Card(
                        key: ValueKey(value.getRelevantIssue(widget.demoIssue).solutions[index]),
                        elevation: 2.0, // Adds a shadow
                        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0), // Margin around each card
                        child: ListTile(
                        title: Text(value.getRelevantIssue(widget.demoIssue).solutions[index].desc),
                        onTap: () => confirmChosenSolution(value.getSolutionList(widget.demoIssue)[index].desc),
                        ),
                    ),
                    onReorder: (int oldIndex, int newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) {
                            newIndex -= 1;
                          }
                          final item = value.getRelevantIssue(widget.demoIssue).solutions.removeAt(oldIndex);
                          value.getRelevantIssue(widget.demoIssue).solutions.insert(newIndex, item);
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
       ) 
      );
  }
}