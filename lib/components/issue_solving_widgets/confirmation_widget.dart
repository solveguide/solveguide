import 'package:flutter/material.dart';
import 'package:guide_solve/models/issue.dart';

enum TestSubject { hypothesis, solution }

class ConfirmationWidget extends StatelessWidget {
  final Issue issue;
  final TestSubject testSubject;
  final VoidCallback onConfirm;

  const ConfirmationWidget({
    super.key,
    required this.issue,
    required this.testSubject,
    required this.onConfirm,
  });

  bool _isEnabled() {
    return (testSubject == TestSubject.hypothesis &&
            issue.hypotheses.isNotEmpty &&
            issue.hypotheses[0].desc.isNotEmpty) ||
        (testSubject == TestSubject.solution &&
            issue.solutions.isNotEmpty &&
            issue.solutions[0].desc.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 500,
        decoration: _containerDecoration(
            Theme.of(context).colorScheme.tertiaryContainer),
        padding: const EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _buildConsensus(context),
                  const SizedBox(height: 10),
                  _buildRelationship(),
                  const SizedBox(height: 10),
                  _buildProposal(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsensus(BuildContext context) {
    String consensusObject = issue.label;
    if (testSubject == TestSubject.solution) {
      consensusObject = issue.root;
    }

    return Text(
      consensusObject,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildRelationship() {
    String relation = "because:";
    if (testSubject == TestSubject.solution) {
      relation = "resolves if I:";
    }

    return Text(
      relation,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.normal,
      ),
    );
  }

  Widget _buildProposal(BuildContext context) {
    String testObject = "?";
    if (testSubject == TestSubject.hypothesis && issue.hypotheses.isNotEmpty) {
      testObject = issue.hypotheses[0].desc;
    } else if (testSubject == TestSubject.solution &&
        issue.solutions.isNotEmpty) {
      testObject = issue.solutions[0].desc;
    }

    return Container(
        decoration: _containerDecoration(
            Theme.of(context).colorScheme.secondaryContainer),
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                testObject,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign
                    .center, // Center the text within the available space
                softWrap: true, // Enable text wrapping
              ),
            ),
            const SizedBox(
                width: 10), // Consistent space between text and button
            Align(
              alignment: Alignment.centerRight, // Align the button to the right
              child: IconButton(
                onPressed: _isEnabled() ? () => onConfirm() : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.tertiaryContainer,
                ),
                icon: const Icon(Icons.check),
              ),
            ),
          ],
        ));
  }

  BoxDecoration _containerDecoration(Color color) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        width: 2,
        color: Colors.black,
      ),
    );
  }
}
