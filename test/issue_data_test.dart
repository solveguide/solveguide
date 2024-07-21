// test/issue_data_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:guide_solve/data/issue_data.dart'; 

void main() {
  group('IssueData', () {
    test('addIssue should add a new issue to the issueList', () {
      final issueData = IssueData();

      // Initial state should have one default issue
      expect(issueData.issues.length, 0);

      // Add a new issue
      issueData.addIssue('New Issue', 'ID');

      // Verify the new issue is added
      expect(issueData.issues.length, 1);
      expect(issueData.issues[0].label, 'New Issue');
    });
    test('getRelevantIssue retrieves the correct issue by label', () {

    final issueData = IssueData();
    issueData.addIssue('bug', 'bugID');
    issueData.addIssue('feature', 'featureID');
    issueData.addIssue('documentation', 'documentationID');

    final result = issueData.getRelevantIssue('feature');

    expect(result.label, 'feature');
  });
      test('getRelevantIssue throws an error when no matching issue is found', () {

    final issueData = IssueData();
    issueData.addIssue('bug', 'bugID');
    issueData.addIssue('feature', 'featureID');
    issueData.addIssue('documentation', 'documentationID');

    expect(() => issueData.getRelevantIssue('nonexistent'), throwsA(isA<StateError>()));
  });

  });
}
