part of 'issue_bloc.dart';

@immutable
sealed class IssueEvent {}

final class IssuesFetched extends IssueEvent {
  final String userId;

  IssuesFetched({required this.userId});
}

final class NewIssueCreated extends IssueEvent {
  final String seedStatement;
  final String ownerId;

  NewIssueCreated({
    required this.seedStatement,
    required this.ownerId,
  });
}

/*

THE FOLLOWING EVENTS ARE RELATED TO THE FOCUS ISSUE AND ISSUE SOLVING PROCESS

*/
final class FocusIssueSelected extends IssueEvent {
  final String issueID;

  FocusIssueSelected({
    required this.issueID,
  });
}

final class NewHypothesisCreated extends IssueEvent {
  final String newHypothesis;

  NewHypothesisCreated({
    required this.newHypothesis,
  });
}

/*

AS OF YET UNUSED DEMO EVENTS

*/
final class DemoIssueStarted extends IssueEvent {}
