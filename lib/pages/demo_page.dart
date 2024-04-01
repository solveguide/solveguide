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

  // create a new hypothesis for this issue
  void createNewHypothesis() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: Text("Possible Root Issue:"),
          content: TextField(
            controller: newHypothesisDescController,
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

  //save Hypothesis
  void save() {
    String newHypothesisDesc = newHypothesisDescController.text;
    Provider.of<IssueData>(context, listen: false)
        .addHypothesis(widget.demoIssue, newHypothesisDesc);
        clear();
  }

  //cancel Hypothesis
  void cancel() {
    Navigator.pop(context);
  }

  //clear controllers
  void clear(){
    newHypothesisDescController.clear();
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
          title: const Text('Find the Root'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: createNewHypothesis,
          backgroundColor: Colors.red,
          tooltip: 'Add a possible root issue',
          child: const Icon(Icons.add),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              buildBlueContainer('Current Issue', widget.demoIssue),
              Expanded(
                    child: ListView.builder(
                      itemCount:
                          value.numberOfHypothesesInIssue(widget.demoIssue),
                      itemBuilder: (context, index) => ListTile(
                        title: Text(value
                            .getRelevantIssue(widget.demoIssue)
                            .hypotheses[index]
                            .desc),
                            leading: Icon(Icons.format_list_numbered),
                            trailing: IconButton(
                              icon: Icon(Icons.arrow_forward),
                              onPressed: () => goToSolutionsPage(widget.demoIssue,value.getHypothesisList(widget.demoIssue)[index].desc)
                      ),
                    ),
                  ),),
            ],
                ),
              ),
          ),
        );
  }
}
