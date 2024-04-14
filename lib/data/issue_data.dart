import 'package:flutter/material.dart';
import 'package:guide_solve/models/hypothesis.dart';
import 'package:guide_solve/models/issue.dart';
import 'package:guide_solve/models/solution.dart';

class IssueData extends ChangeNotifier{

/*

ISSUE DATA STRUCTURE

- This overall list contains all user Issues
- Each Issue has a label and other optional fields

*/

List<Issue> issueList = [
  //default list
  Issue(
    label: "I am concerned this demo is a waste of time", 
    hypotheses: [] )
];

// get list of Issues
List<Issue> getIssueList() {
  return issueList;
}

// get list of hypotheses
List<Hypothesis> getHypothesisList(String issue){
  return getRelevantIssue(issue).hypotheses;
}

// get number of hypothesis in issue
int numberOfHypothesesInIssue(String issueLabel){
  Issue relevantIssue = getRelevantIssue(issueLabel);
  return relevantIssue.hypotheses.length;
}

// add a new Issue
void addIssue(String label){
  //add a new issue with a blank list of root theories
  issueList.add(Issue(label: label, hypotheses: []));
  notifyListeners();
}

// add hypotheses to an Issue
void addHypothesis(String issueLabel, String desc){
  //find the relevant Issue
  Issue relevantIssue = getRelevantIssue(issueLabel);

  relevantIssue.hypotheses.add(Hypothesis(desc: desc));
  notifyListeners();
}

// mark one hypothesis as the root
void selectRoot(String issueLabel, String hypothesisDesc){
  //find the relevant Issue
Hypothesis relevantHypothesis = getRelevantHypothesis(issueLabel, hypothesisDesc);
//check isRoot
relevantHypothesis.isRoot = !relevantHypothesis.isRoot;
notifyListeners();
}

// add a solution to an Issue
void addSolution(String issueLabel, String desc){
  //find the relevant Issue
  Issue relevantIssue = getRelevantIssue(issueLabel);

  relevantIssue.solutions.add(Solution(desc: desc));
  notifyListeners();
}

// get list of hypotheses
List<Solution> getSolutionList(String issue){
  return getRelevantIssue(issue).solutions;
}

// get number of solutions in issue
int numberOfSolutionsInIssue(String issueLabel){
  Issue relevantIssue = getRelevantIssue(issueLabel);
  return relevantIssue.solutions.length;
}

// set the root theory
void setRoot(String issueLabel, String rootTheory){
Issue relevantIssue = getRelevantIssue(issueLabel);
relevantIssue.root = rootTheory;
}

// set the root solve
void setSolve(String issueLabel, String solution){
Issue relevantIssue = getRelevantIssue(issueLabel);
relevantIssue.solve = solution;
}

//build solve statement
RichText buildSolveStatement(String issueLabel) {
  Issue relevantIssue = getRelevantIssue(issueLabel);
  return RichText(
    text: TextSpan(
      // Default text style for all spans
      style: TextStyle(fontSize: 16, color: Colors.black),
      children: [
        TextSpan(text: 'You will: ', style: TextStyle(fontWeight: FontWeight.bold)),
        TextSpan(text: '${relevantIssue.solve}.\n\n', style: TextStyle(fontWeight: FontWeight.normal)),
        TextSpan(text: 'Because it addresses: ', style: TextStyle(fontWeight: FontWeight.bold)),
        TextSpan(text: '${relevantIssue.root}.\n\n', style: TextStyle(fontWeight: FontWeight.normal)),
        TextSpan(text: 'Which is the root issue driving: ', style: TextStyle(fontWeight: FontWeight.bold)),
        TextSpan(text: '${relevantIssue.label}', style: TextStyle(fontWeight: FontWeight.normal)),
      ],
    ),
  );
}

// Mark an Issue as Solved

//Helpers
//return relevant Issue given Issue Label
Issue getRelevantIssue(String issueLabel){
  Issue relevantIssue = issueList.firstWhere((issue) => issue.label == issueLabel);
  return relevantIssue;
}

//return relevant Hypothesis given Hypothesis desc
Hypothesis getRelevantHypothesis(String issueLabel, String hypothesisDesc){
  //find relevant issue first
  Issue relevantIssue = getRelevantIssue(issueLabel);
  // then find the relevant hypothesis
  Hypothesis relevantHypothesis = relevantIssue.hypotheses.firstWhere((hypothesis) => hypothesis.desc == hypothesisDesc);
return relevantHypothesis;
}
}