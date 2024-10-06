part of 'issue_bloc.dart';

@immutable
abstract class IssueEvent extends Equatable {
  const IssueEvent();

  @override
  List<Object?> get props => [];
}

final class IssuesFetched extends IssueEvent {
  const IssuesFetched();

  @override
  List<Object?> get props => [];
}

final class NewIssueCreated extends IssueEvent {
  final String seedStatement;

  const NewIssueCreated({
    required this.seedStatement,
  });

  @override
  List<Object?> get props => [seedStatement];
}

final class IssueDeletionRequested extends IssueEvent {
  final String issueId;

  const IssueDeletionRequested({
    required this.issueId,
  });

  @override
  List<Object?> get props => [issueId];
}

/*

THE FOLLOWING EVENTS ARE RELATED TO THE FOCUS ISSUE AND ISSUE SOLVING PROCESS

*/
final class FocusIssueSelected extends IssueEvent {
  final String issueID;

  const FocusIssueSelected({
    required this.issueID,
  });

  @override
  List<Object?> get props => [issueID];
}

class FocusedIssueUpdated extends IssueEvent {
  final Issue focusedIssue;

  const FocusedIssueUpdated(this.focusedIssue);

  @override
  List<Object?> get props => [focusedIssue];
}

final class NewHypothesisCreated extends IssueEvent {
  final String newHypothesis;

  const NewHypothesisCreated({
    required this.newHypothesis,
  });

  @override
  List<Object?> get props => [newHypothesis];
}

class HypothesisUpdated extends IssueEvent {
  final String hypothesisId;
  final String updatedDescription;

  const HypothesisUpdated({
    required this.hypothesisId,
    required this.updatedDescription,
  });

  @override
  List<Object?> get props => [hypothesisId, updatedDescription];
}

class CreateSeparateIssueFromHypothesis extends IssueEvent {
  final String hypothesisId;
  final bool newIssuePrioritized;

  const CreateSeparateIssueFromHypothesis({
    required this.hypothesisId,
    required this.newIssuePrioritized,
  });

  @override
  List<Object?> get props => [hypothesisId, newIssuePrioritized];
}

final class FocusRootConfirmed extends IssueEvent {
  final String confirmedRootHypothesisId;

  const FocusRootConfirmed({
    required this.confirmedRootHypothesisId,
  });

  @override
  List<Object?> get props => [confirmedRootHypothesisId];
}

final class NewSolutionCreated extends IssueEvent {
  final String newSolution;

  const NewSolutionCreated({
    required this.newSolution,
  });

  @override
  List<Object?> get props => [newSolution];
}

class SolutionUpdated extends IssueEvent {
  final String solutionId;
  final String updatedDescription;

  const SolutionUpdated({
    required this.solutionId,
    required this.updatedDescription,
  });

  @override
  List<Object?> get props => [solutionId, updatedDescription];
}

final class FocusSolveScopeSubmitted extends IssueEvent {
  final String solutionId;

  const FocusSolveScopeSubmitted({
    required this.solutionId,
  });

  @override
  List<Object?> get props => [solutionId];
}

final class FocusSolveConfirmed extends IssueEvent {
  final String solutionId;

  const FocusSolveConfirmed({required this.solutionId});

  @override
  List<Object?> get props => [solutionId];
}


final class NewFactCreated extends IssueEvent {
  final String newFact; // The fact description
  final String newFactContext; // Context or reasoning for the fact
  final String referenceObjectId; // The ID of the object being referenced
  final ReferenceObjectType referenceObjectType; // The type of object being referenced

  const NewFactCreated({
    required this.newFact,
    required this.newFactContext,
    required this.referenceObjectId,
    required this.referenceObjectType,
  });

  @override
  List<Object?> get props => [newFact, newFactContext, referenceObjectId, referenceObjectType];
}

/*

THE FOLLOWING EVENTS ARE RELATED TO THE SOLUTION PROVING & TRACKING PROCESS

*/

final class SolveProvenByOwner extends IssueEvent {
  final Issue issue;

  const SolveProvenByOwner({
    required this.issue,
  });

  @override
  List<Object?> get props => [issue];
}

final class SolveDisprovenByOwner extends IssueEvent {
  final Issue issue;

  const SolveDisprovenByOwner({
    required this.issue,
  });

  @override
  List<Object?> get props => [issue];
}

/*

AS OF YET UNUSED DEMO EVENTS

*/
final class DemoIssueStarted extends IssueEvent {}
