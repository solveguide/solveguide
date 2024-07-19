// test/issue_data_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:guide_solve/data/issue_data.dart'; // Update with your actual import

void main() {
  group('IssueData', () {
    test('addIssue should add a new issue to the issueList', () {
      final issueData = IssueData();

      // Initial state should have one default issue
      expect(issueData.issues.length, 1);

      // Add a new issue
      issueData.addIssue('New Issue');

      // Verify the new issue is added
      expect(issueData.issues.length, 2);
      expect(issueData.issues[1].label, 'New Issue');
    });
  });
}
