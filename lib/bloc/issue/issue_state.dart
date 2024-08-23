part of 'issue_bloc.dart';

@immutable
sealed class IssueState {}

final class IssueInitial extends IssueState {}

final class IssuesListSuccess extends IssueState {
  final List<Issue> issueList;

  IssuesListSuccess({required this.issueList});
}

final class IssuesListLoading extends IssueState {}

final class IssuesListFailure extends IssueState {
  final String error;

  IssuesListFailure(this.error);
}

final class IssueFocusedState extends IssueState {
  final Issue focusedIssue;

  IssueFocusedState({required this.focusedIssue});
}
