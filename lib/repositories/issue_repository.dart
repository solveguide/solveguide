import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guide_solve/models/issue.dart';

class IssueRepository {
  // Get collection of issues
  final CollectionReference _issuesCollection =
      FirebaseFirestore.instance.collection('issues');

  // Get issues from database
  Stream<List<Issue>> getIssuesStream() {
    return _issuesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Issue.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    }).handleError((error) {
      throw error.toString();
    });
  }

  // Create an issue
  Future<void> addIssue(Issue issue) async {
    try {
      await _issuesCollection.add(issue.toJson());
    } catch (error) {
      throw error.toString();
    }
  }

  // Update an issue
  Future<void> updateIssue(String issueId, Issue issue) async {
    try {
      await _issuesCollection.doc(issueId).update(issue.toJson());
    } catch (error) {
      throw error.toString();
    }
  }

  // Delete an issue
  Future<void> deleteIssue(String issueId) async {
    try {
      await _issuesCollection.doc(issueId).delete();
    } catch (error) {
      throw error.toString();
    }
  }
}
