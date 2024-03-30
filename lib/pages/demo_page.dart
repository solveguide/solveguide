import 'package:flutter/material.dart';
import 'package:guide_solve/components/blue_container.dart';
import 'package:guide_solve/data/issue_data.dart';
import 'package:provider/provider.dart';

class DemoPage extends StatefulWidget {
  final String demoIssue;
  const DemoPage({super.key, required this.demoIssue});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

//UI
class _DemoPageState extends State<DemoPage> {
  void createNewHypothesis() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Widen Possible Root Issues"),
      ),
    );
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
          child: const Icon(Icons.add),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              buildBlueContainer('Current Issue', widget.demoIssue),
              Expanded(
                child: ListView.builder(
                  itemCount: value.numberOfHypothesesInIssue(widget.demoIssue),
                  itemBuilder: (context, index) => ListTile(
                    title: Text(value.getRelevantIssue(widget.demoIssue).hypotheses[index].desc),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
