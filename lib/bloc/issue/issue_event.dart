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
  const NewIssueCreated({
    required this.seedStatement,
  });
  final String seedStatement;

  @override
  List<Object?> get props => [seedStatement];
}

final class IssueDeletionRequested extends IssueEvent {
  const IssueDeletionRequested({
    required this.issueId,
  });
  final String issueId;

  @override
  List<Object?> get props => [issueId];
}

/*

THE FOLLOWING EVENTS ARE RELATED TO THE FOCUS ISSUE AND ISSUE SOLVING PROCESS

*/
final class FocusIssueSelected extends IssueEvent {
  const FocusIssueSelected({
    required this.issueId,
  });
  final String issueId;

  @override
  List<Object?> get props => [issueId];
}

class FocusedIssueUpdated extends IssueEvent {
  const FocusedIssueUpdated(this.focusedIssue);
  final Issue focusedIssue;

  @override
  List<Object?> get props => [focusedIssue];
}

final class NewHypothesisCreated extends IssueEvent {
  const NewHypothesisCreated({
    required this.newHypothesis,
  });
  final String newHypothesis;

  @override
  List<Object?> get props => [newHypothesis];
}

class HypothesisUpdated extends IssueEvent {
  const HypothesisUpdated({
    required this.hypothesisId,
    required this.updatedDescription,
  });
  final String hypothesisId;
  final String updatedDescription;

  @override
  List<Object?> get props => [hypothesisId, updatedDescription];
}

class HypothesisVoteSubmitted extends IssueEvent {
  const HypothesisVoteSubmitted({
    required this.hypothesisId,
    required this.voteValue,
  });
  final String hypothesisId;
  final String voteValue;

  @override
  List<Object?> get props => [hypothesisId, voteValue];
}

class CreateSeparateIssueFromHypothesis extends IssueEvent {
  const CreateSeparateIssueFromHypothesis({
    required this.hypothesisId,
    required this.newIssuePrioritized,
  });
  final String hypothesisId;
  final bool newIssuePrioritized;

  @override
  List<Object?> get props => [hypothesisId, newIssuePrioritized];
}

final class FocusRootConfirmed extends IssueEvent {
  const FocusRootConfirmed({
    required this.confirmedRootHypothesisId,
  });
  final String confirmedRootHypothesisId;

  @override
  List<Object?> get props => [confirmedRootHypothesisId];
}

final class NewSolutionCreated extends IssueEvent {
  const NewSolutionCreated({
    required this.newSolution,
  });
  final String newSolution;

  @override
  List<Object?> get props => [newSolution];
}

class SolutionUpdated extends IssueEvent {
  const SolutionUpdated({
    required this.solutionId,
    required this.updatedDescription,
  });
  final String solutionId;
  final String updatedDescription;

  @override
  List<Object?> get props => [solutionId, updatedDescription];
}

class SolutionVoteSubmitted extends IssueEvent {
  const SolutionVoteSubmitted({
    required this.solutionId,
    required this.voteValue,
  });
  final String solutionId;
  final String voteValue;

  @override
  List<Object?> get props => [solutionId, voteValue];
}

final class FocusSolveScopeSubmitted extends IssueEvent {
  const FocusSolveScopeSubmitted({
    required this.solutionId,
  });
  final String solutionId;

  @override
  List<Object?> get props => [solutionId];
}

final class FocusSolveConfirmed extends IssueEvent {
  const FocusSolveConfirmed({required this.solutionId});
  final String solutionId;

  @override
  List<Object?> get props => [solutionId];
}

final class FocusIssueNavigationRequested extends IssueEvent {
  const FocusIssueNavigationRequested({required this.stage});
  final IssueProcessStage stage;

  @override
  List<Object?> get props => [stage];
}

final class NewFactCreated extends IssueEvent {
  const NewFactCreated({
    required this.newFact,
    required this.newFactContext,
    required this.referenceObjectId,
    required this.referenceObjectType,
  });
  final String newFact; // The fact description
  final String newFactContext; // Context or reasoning for the fact
  final String referenceObjectId; // The ID of the object being referenced
  final ReferenceObjectType referenceObjectType;

  @override
  List<Object?> get props =>
      [newFact, newFactContext, referenceObjectId, referenceObjectType];
}

class AddUserToIssueEvent extends IssueEvent {
  final String issueId;
  final String userId;

  const AddUserToIssueEvent({required this.issueId, required this.userId});

  @override
  List<Object?> get props => [issueId, userId];
}

/*

THE FOLLOWING EVENTS ARE RELATED TO THE SOLUTION PROVING & TRACKING PROCESS

*/

final class SolveProvenByOwner extends IssueEvent {
  const SolveProvenByOwner({
    required this.issue,
  });
  final Issue issue;

  @override
  List<Object?> get props => [issue];
}

final class SolveDisprovenByOwner extends IssueEvent {
  const SolveDisprovenByOwner({
    required this.issue,
  });
  final Issue issue;

  @override
  List<Object?> get props => [issue];
}

/*

AS OF YET UNUSED DEMO EVENTS

*/
final class DemoIssueStarted extends IssueEvent {}
