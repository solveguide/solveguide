import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guide_solve/models/issue.dart';

class IssueRepository {
  // Get collection of issues
  final CollectionReference _issuesCollection =
      FirebaseFirestore.instance.collection('issues');

  // Get issues from database
  Stream<List<Issue>> getIssuesStream(String currentUserId) {
    return _issuesCollection
        .where('ownerId', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Issue.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    }).handleError((error) {
      throw error.toString();
    });
  }

  Future<List<Issue>> getIssueList(String currentUserId) async {
    try {
      // Fetch the snapshot from Firestore
      final snapshot = await _issuesCollection
          .where('ownerId', isEqualTo: currentUserId)
          .get(); // Use get() instead of snapshots()

      // Convert the snapshot into a List of Issue objects
      return snapshot.docs.map((doc) {
        return Issue.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (error) {
      // Handle any errors that occur
      throw error.toString();
    }
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

  // Spinoff an issue
  Future<String> addSpinoffIssue(
      Issue oldIssue, String spinoffHypothesis, String ownerId) async {
    final newIssue = Issue(
      label: spinoffHypothesis,
      seedStatement: oldIssue.seedStatement,
      spinoffSourceIssueId: oldIssue.issueId,
      ownerId: ownerId, // Use ownerId from AuthState
      createdTimestamp: oldIssue.createdTimestamp,
      lastUpdatedTimestamp: DateTime.now(),
      root: oldIssue.root,
      solve: oldIssue.solve,
      hypotheses: oldIssue.hypotheses,
      solutions: oldIssue.solutions,
      invitedUserIds: oldIssue.invitedUserIds,
    );
    try {
      final docRef = await _issuesCollection.add(newIssue.toJson());
      await docRef.update({'issueId': docRef.id});
      return docRef.id;
    } catch (error) {
      throw error.toString();
    }
  }

  // Update an issue
  Future<void> updateIssue(String issueId, Issue issue) async {
    Issue updatedIssue = issue.copyWith(
      root: issue.root,
      solve: issue.solve,
      hypotheses: issue.hypotheses,
      solutions: issue.solutions,
      invitedUserIds: issue.invitedUserIds,
      lastUpdatedTimestamp: DateTime.now(),
    );
    try {
      await _issuesCollection.doc(issueId).update(updatedIssue.toJson());
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

/*
LOCAL iSSUE MANIPULATING FUNCTIONS
*/
  Issue? _focusedIssue;

  // Method to set the focused issue
  void setFocusIssue(Issue issue) {
    _focusedIssue = issue;
  }

  // Method to get the focused issue
  Issue? getFocusIssue() {
    return _focusedIssue;
  }
}
