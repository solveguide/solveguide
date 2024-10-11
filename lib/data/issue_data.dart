//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guide_solve/models/issue.dart';

class IssueData extends ChangeNotifier {
  final List<Issue> _issues = [];
  Issue? _demoIssue;

  // Getter for the list of issues
  List<Issue> get issues => _issues;

  // Getter for the demo issue
  Issue? get demoIssue => _demoIssue;

  Future<void> saveDemoIssue() async {
    if (_demoIssue != null) {
      await FirebaseFirestore.instance
          .collection('issues')
          .doc(_demoIssue!.issueId)
          .set(getRelevantIssue(_demoIssue!.label).toJson());
      notifyListeners();
    }
  }

//build solve statement
  RichText buildSolveStatement(String issueLabel) {
    final relevantIssue = getRelevantIssue(issueLabel);
    return RichText(
      text: TextSpan(
        // Default text style for all spans
        style: const TextStyle(fontSize: 16, color: Colors.black),
        children: [
          const TextSpan(
            text: 'You will: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: '${relevantIssue.solve}.\n\n',
            style: const TextStyle(fontWeight: FontWeight.normal),
          ),
          const TextSpan(
            text: 'Because it addresses: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: '${relevantIssue.root}.\n\n',
            style: const TextStyle(fontWeight: FontWeight.normal),
          ),
          const TextSpan(
            text: 'Which is the root issue driving: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: relevantIssue.label,
            style: const TextStyle(fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }

// Mark an Issue as Solved

//Helpers
//return relevant Issue given Issue Label
  Issue getRelevantIssue(String issueLabel) {
    final relevantIssue =
        _issues.firstWhere((issue) => issue.label == issueLabel);
    return relevantIssue;
  }
}
