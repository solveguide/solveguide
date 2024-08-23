import 'package:flutter/material.dart';
import 'package:guide_solve/models/issue.dart';

enum TestSubject { hypothesis, solution }

class ConfirmationWidget extends StatelessWidget {
  final Issue issue;
  final TestSubject testSubject;

  const ConfirmationWidget({
    super.key,
    required this.issue,
    required this.testSubject,
  });

  bool _isEnabled() {
    return (testSubject == TestSubject.hypothesis &&
            issue.hypotheses.isNotEmpty &&
            issue.hypotheses[0].desc.isNotEmpty) ||
        (testSubject == TestSubject.solution &&
            issue.solutions.isNotEmpty &&
            issue.solutions[0].desc.isNotEmpty);
  }

  void _onConfirm(BuildContext context) {
    if (_isEnabled()) {
      if (testSubject == TestSubject.hypothesis) {
        // TO-DO: Send Confirm Root Event
      } else if (testSubject == TestSubject.solution) {
        // TO-DO: Send Confirm Root Event
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  _buildConsensus(context),
                  const SizedBox(height: 10),
                  _buildRelationship(),
                  const SizedBox(height: 10),
                  _buildProposal(),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _isEnabled() ? () => _onConfirm(context) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.tertiaryContainer,
              ),
              child: const Text("Confirm"),
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

    return Container(
      decoration: _innerContainerDecoration(
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

  Widget _buildRelationship() {
    String relation = "because:";
    if (testSubject == TestSubject.solution) {
      relation = "resolves if I:";
    }

    return Text(
      relation,
      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal),
    );
  }

  Widget _buildProposal() {
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

  BoxDecoration _innerContainerDecoration(Color color) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(width: 2, color: Colors.black),
    );
  }
}
