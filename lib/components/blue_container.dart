import 'package:flutter/material.dart';
import 'package:guide_solve/data/issue_data.dart';
import 'package:guide_solve/models/issue.dart';
import 'package:guide_solve/pages/solutions_page.dart';
import 'package:guide_solve/pages/solve_page.dart';
import 'package:provider/provider.dart';

enum TestSubject { hypothesis, solution }

Widget buildBlueContainer(
    BuildContext context, Issue issue, TestSubject testSubject) {
  bool isEnabled = (testSubject == TestSubject.hypothesis &&
          issue.hypotheses.isNotEmpty &&
          issue.hypotheses[0].desc.isNotEmpty) ||
      (testSubject == TestSubject.solution &&
          issue.solutions.isNotEmpty &&
          issue.solutions[0].desc.isNotEmpty);

  return Center(
    child: Container(
      width: 500,
      decoration: _containerDecoration(
          Theme.of(context).colorScheme.secondaryContainer),
      padding: const EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildConsensus(context, issue, testSubject),
                const SizedBox(height: 10),
                _buildrelationship(testSubject),
                const SizedBox(height: 10),
                _buildProposal(issue, testSubject),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: isEnabled
                ? () {
                    if (testSubject == TestSubject.hypothesis) {
                      Navigator.pop(context);
                      Provider.of<IssueData>(context, listen: false)
                          .setRoot(issue);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SolutionsPage(
                              demoIssue: issue.label, root: issue.root),
                        ),
                      );
                    } else if (testSubject == TestSubject.solution) {
                      Navigator.pop(context);
                      Provider.of<IssueData>(context, listen: false)
                          .setSolve(issue);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SolvePage(
                              demoIssue: issue.label,
                              root: issue.root,
                              solve: issue.solve),
                        ),
                      );
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
            ),
            child: const Text("Confirm"),
          ),
        ],
      ),
    ),
  );
}

Widget _buildConsensus(
    BuildContext context, Issue issue, TestSubject testSubject) {
  String consensusObject = issue.label;
  if (testSubject == TestSubject.solution) {
    consensusObject = issue.root;
  }

  return Container(
    decoration: _innercontainerDecoration(
        Theme.of(context).colorScheme.tertiaryContainer),
    padding: const EdgeInsets.all(8),
    child: Text(
      consensusObject,
      style: const TextStyle(
        fontSize: 20,
      ),
    ),
  );
}

Widget _buildrelationship(TestSubject testSubject) {
  String relation = "because:";
  if (testSubject == TestSubject.solution) {
    relation = "resolves if I:";
  }

  return Text(
    relation,
    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal),
  );
}

Widget _buildProposal(Issue issue, TestSubject testSubject) {
  String testObject = "?";
  if (testSubject == TestSubject.hypothesis && issue.hypotheses.isNotEmpty) {
    testObject = issue.hypotheses[0].desc;
  } else if (testSubject == TestSubject.solution &&
      issue.solutions.isNotEmpty) {
    testObject = issue.solutions[0].desc;
  }

  return Text(
    testObject,
    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
  );
}

BoxDecoration _containerDecoration(Color color) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(width: 5, color: Colors.black),
  );
}

BoxDecoration _innercontainerDecoration(Color color) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(width: 2, color: Colors.black),
  );
}
