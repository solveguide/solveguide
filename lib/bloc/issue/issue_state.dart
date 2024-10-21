part of 'issue_bloc.dart';

@immutable
abstract class IssueState extends Equatable {
  const IssueState();

  @override
  List<Object?> get props => [];
}

final class IssueInitial extends IssueState {}

final class IssuesListSuccess extends IssueState {
  const IssuesListSuccess({required this.issueList});
  final List<Issue> issueList;

  @override
  List<Object?> get props => [issueList];
}

final class IssuesListLoading extends IssueState {}

final class IssuesListFailure extends IssueState {
  const IssuesListFailure(this.error);
  final String error;

  @override
  List<Object?> get props => [error];
}

// States related to the issue-solving process
class IssueProcessState extends IssueState {
  const IssueProcessState({
    required this.stage,
    this.hypothesesStream,
    this.solutionsStream,
    this.perspective,
  });

  final IssueProcessStage stage;
  final Stream<List<Hypothesis>>? hypothesesStream;
  final Stream<List<Solution>>? solutionsStream;
  final IssuePerspective? perspective;

  @override
  List<Object?> get props =>
      [stage, hypothesesStream, solutionsStream, perspective];
}

enum IssueProcessStage {
  wideningHypotheses,
  establishingFacts,
  narrowingToRootCause,
  wideningSolutions,
  narrowingToSolve,
  scopingSolve,
  solveSummaryReview,
}

// abstract class IssueInFocus extends IssueState {
//   final Issue focusedIssue;

//   const IssueInFocus({required this.focusedIssue});

//   @override
//   List<Object?> get props => [focusedIssue];
// }

// final class IssueInFocusInitial extends IssueInFocus {
//   const IssueInFocusInitial({required super.focusedIssue});
// }

// final class IssueInFocusRootIdentified extends IssueInFocus {
//   final String rootCause;

//   const IssueInFocusRootIdentified({
//     required super.focusedIssue,
//     required this.rootCause,
//   });

//   @override
//   List<Object?> get props => [focusedIssue, rootCause];
// }

// final class IssueInFocusSolutionIdentified extends IssueInFocus {
//   final String solution;

//   const IssueInFocusSolutionIdentified({
//     required super.focusedIssue,
//     required this.solution,
//   });

//   @override
//   List<Object?> get props => [focusedIssue, solution];
// }

// final class IssueInFocusSolved extends IssueInFocus {
//   const IssueInFocusSolved({
//     required super.focusedIssue,
//   });
// }
