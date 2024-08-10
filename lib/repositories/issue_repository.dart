import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guide_solve/models/issue.dart';

class IssueRepository {
  // Get collection of issues
  final CollectionReference _issuesCollection =
      FirebaseFirestore.instance.collection('issues');

  // Get issues from database
  Stream<List<Issue>> getIssuesStream(String currentUserId) {
    return _issuesCollection.where('ownerId', isEqualTo: currentUserId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Issue.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    }).handleError((error) {
      throw error.toString();
    });
  }

  // Create an issue
  Future<void> addIssue(String seedStatement, String ownerId) async {
    final newIssue = Issue(
                  label: seedStatement,
                  seedStatement: seedStatement,
                  ownerId: ownerId, // Use ownerId from AuthState
                  createdTimestamp: DateTime.now(),
                  lastUpdatedTimestamp: DateTime.now(),
                  //issueId: 'dashboard_${DateTime.now().millisecondsSinceEpoch}',
                );
    try {
      final docRef = await _issuesCollection.add(newIssue.toJson());
      await docRef.update({'issueId': docRef.id});
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