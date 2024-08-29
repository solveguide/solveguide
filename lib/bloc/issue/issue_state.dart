part of 'issue_bloc.dart';

@immutable
abstract class IssueState extends Equatable {
  const IssueState();

  @override
  List<Object?> get props => [];
}

final class IssueInitial extends IssueState {}

final class IssuesListSuccess extends IssueState {
  final List<Issue> issueList;

  const IssuesListSuccess({required this.issueList});

  @override
  List<Object?> get props => [issueList];
}

final class IssuesListLoading extends IssueState {}

final class IssuesListFailure extends IssueState {
  final String error;

  const IssuesListFailure(this.error);

  @override
  List<Object?> get props => [error];
}

abstract class IssueInFocus extends IssueState {
  final Issue focusedIssue;

  const IssueInFocus({required this.focusedIssue});

  @override
  List<Object?> get props => [focusedIssue];
}

final class IssueInFocusInitial extends IssueInFocus {
  const IssueInFocusInitial({required super.focusedIssue});
}

final class IssueInFocusRootIdentified extends IssueInFocus {
  final String rootCause;

  const IssueInFocusRootIdentified({
    required super.focusedIssue,
    required this.rootCause,
  });

  @override
  List<Object?> get props => [focusedIssue, rootCause];
}

final class IssueInFocusSolutionIdentified extends IssueInFocus {
  final String solution;

  const IssueInFocusSolutionIdentified({
    required super.focusedIssue,
    required this.solution,
  });

  @override
  List<Object?> get props => [focusedIssue, solution];
}

final class IssueInFocusSolved extends IssueInFocus {
  const IssueInFocusSolved({
    required super.focusedIssue,
  });
}
