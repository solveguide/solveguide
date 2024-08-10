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

final class FocusIssueSelected extends IssueEvent {
  final String issueID;

  FocusIssueSelected({
    required this.issueID,
  });
}

final class DemoIssueStarted extends IssueEvent {}
