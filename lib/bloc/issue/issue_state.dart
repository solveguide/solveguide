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

sealed class IssueInFocus extends IssueState {
  final Issue focusedIssue;

  IssueInFocus({required this.focusedIssue});
}

final class IssueInFocusInitial extends IssueInFocus {
  IssueInFocusInitial({required super.focusedIssue});
}

final class IssueInFocusRootIdentified extends IssueInFocus {
  final String rootCause;

  IssueInFocusRootIdentified({
    required super.focusedIssue, // directly pass to the superclass
    required this.rootCause,
  });
}

final class IssueInFocusSolutionIdentified extends IssueInFocus {
  final String solution;

  IssueInFocusSolutionIdentified({
    required super.focusedIssue, // directly pass to the superclass
    required this.solution,
  });
}

final class IssueInFocusSolved extends IssueInFocus {

  IssueInFocusSolved({
    required super.focusedIssue, // directly pass to the superclass
  });
}
