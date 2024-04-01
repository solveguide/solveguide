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

  // create a new solution for this issue
  void createNewSolution() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: Text("Possible Solution:"),
          content: TextField(
            controller: newSolutionNameController,
          ),
          actions: [
            //save button
            MaterialButton(
              onPressed: save,
              child: Text("Add"),
            ),

            //cancel button
            MaterialButton(
              onPressed: cancel,
              child: Text("cancel"),
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
  }

  //stop adding Solutions
  void cancel() {
    Navigator.pop(context);
  }

  //clear controllers
  void clear(){
    newSolutionNameController.clear();
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
          title: const Text('List Possible Solutions'),
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
                    child: ListView.builder(
                      itemCount:
                          value.numberOfSolutionsInIssue(widget.demoIssue),
                      itemBuilder: (context, index) => ListTile(
                        title: Text(value
                            .getRelevantIssue(widget.demoIssue)
                            .solutions[index]
                            .desc),
                            leading: Icon(Icons.format_list_numbered),
                            trailing: IconButton(
                              icon: Icon(Icons.arrow_forward),
                              onPressed: () => goToSolvePage(widget.demoIssue,value.getSolutionList(widget.demoIssue)[index].desc)
                      ),
                    ),
                  ),),
            ],
                ),
              ),
      ) 
      );
  }
}