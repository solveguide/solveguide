part of 'issue_bloc.dart';

@immutable
sealed class IssueEvent {}

final class IssuesFetched extends IssueEvent {}

final class FocusIssueSelected extends IssueEvent {
  final String issueID;

  FocusIssueSelected({
    required this.issueID,
  });
}

final class DemoIssueStarted extends IssueEvent {}
