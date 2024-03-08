import 'package:guide_solve/models/issue.dart';

class IssueData{

/*

ISSUE DATA STRUCTURE

- This overall list contains all user Issues
- Each Issue has a label and other optional fields

*/

List<Issue> issueList = [
  //default list
  Issue(
    label: "I am concerned this is a waste of time", 
    root: "I need help", 
    rootTheories: [] )
];

// get list of Issues
List<Issue> getIssueList() {
  return issueList;
}

// add a new Issue
void addIssue(String label){
  //add a new issue with a blank list of root theories
  issueList.add(Issue(label: label, root: "", rootTheories: []));
}

// prioritize Issues

// Solve an Issue

// Mark an Issue as Solved

}