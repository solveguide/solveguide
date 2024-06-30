import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:guide_solve/models/issue.dart';

class FirestoreService {
  //get collection of issues
  final CollectionReference issues =
      FirebaseFirestore.instance.collection('issues');

  //create a new issue
  Future<void> addIssue(String issueLabel) {
    return issues.add({
      'label': issueLabel,
      'timestamp': Timestamp.now(),
      'root': "I can't accept things this way.",
      'solve': "I accept things this way.",
    });
  }

  //get an issue from database
  Stream<QuerySnapshot> getIssuesStream() {
    final issuesStream =
        issues.orderBy('timestamp', descending: true).snapshots();

    return issuesStream;
  }

  //update an issue

  //delete an issue
}
