import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guide_solve/models/issue.dart';
//import 'package:guide_solve/models/issue.dart';

class FirestoreService {
  //get collection of issues
  final CollectionReference _issuesCollection = FirebaseFirestore.instance.collection('issues');


  //get an issue from database
  Stream<List<Issue>> getIssuesStream() {
    return _issuesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Issue.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  //create an issue
    Future<void> addIssue(Issue issue) {
    return _issuesCollection.add(issue.toJson());
  }

  //update an issue

  //delete an issue
}
