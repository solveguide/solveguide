import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guide_solve/models/issue.dart';

class FirestoreService {
  // Get collection of issues
  final CollectionReference _issuesCollection =
      FirebaseFirestore.instance.collection('issues');

  // Get an issue from database
  Stream<List<Issue>> getIssuesStream() {
    return _issuesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Issue.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    }).handleError((error) {
      //print('Error getting issues stream: $error');
      // Handle the error appropriately, for example by showing a message to the user
    });
  }

  // Create an issue
  Future<void> addIssue(Issue issue) async {
    try {
      await _issuesCollection.add(issue.toJson());
    } catch (error) {
      //print('Error adding issue: $error');
      // Handle the error appropriately, for example by showing a message to the user
    }
  }

  // Update an issue
  Future<void> updateIssue(String issueId, Issue issue) async {
    try {
      await _issuesCollection.doc(issueId).update(issue.toJson());
    } catch (error) {
      //print('Error updating issue: $error');
      // Handle the error appropriately, for example by showing a message to the user
    }
  }

  // Delete an issue
  Future<void> deleteIssue(String issueId) async {
    try {
      await _issuesCollection.doc(issueId).delete();
    } catch (error) {
      //print('Error deleting issue: $error');
      // Handle the error appropriately, for example by showing a message to the user
    }
  }
}
