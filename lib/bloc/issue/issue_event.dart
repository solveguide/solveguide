part of 'issue_bloc.dart';

@immutable
abstract class IssueEvent extends Equatable {
  const IssueEvent();

  @override
  List<Object?> get props => [];
}

final class IssuesFetched extends IssueEvent {
  final String userId;

  const IssuesFetched({required this.userId});

  @override
  List<Object?> get props => [userId];
}

final class NewIssueCreated extends IssueEvent {
  final String seedStatement;
  final String ownerId;

  const NewIssueCreated({
    required this.seedStatement,
    required this.ownerId,
  });

  @override
  List<Object?> get props => [seedStatement, ownerId];
}
/*

THE FOLLOWING EVENTS ARE RELATED TO THE FOCUS ISSUE AND ISSUE SOLVING PROCESS

*/
final class FocusIssueSelected extends IssueEvent {
  final String issueID;
  final String userId;

  const FocusIssueSelected({
    required this.issueID,
    required this.userId,
  });

  @override
  List<Object?> get props => [issueID, userId];
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
  final int index;
  final Hypothesis updatedHypothesis;

  const HypothesisUpdated({
    required this.index,
    required this.updatedHypothesis,
  });

  @override
  List<Object?> get props => [index, updatedHypothesis];
}

class CreateSeparateIssueFromHypothesis extends IssueEvent {
  final int index;
  final Hypothesis hypothesis;
  final bool newIssuePrioritized;
  final String ownerId;

  const CreateSeparateIssueFromHypothesis({
    required this.index,
    required this.hypothesis,
    required this.newIssuePrioritized,
    required this.ownerId,
  });

  @override
  List<Object?> get props => [index, hypothesis, newIssuePrioritized, ownerId];
}

class HypothesisListResorted<T> extends IssueEvent {
  final List<Hypothesis> items;
  final int oldIndex;
  final int newIndex;

  const HypothesisListResorted({
    required this.items,
    required this.oldIndex,
    required this.newIndex,
  });

  @override
  List<Object?> get props => [items, oldIndex, newIndex];
}

final class FocusRootConfirmed extends IssueEvent {
  final String confirmedRoot;

  const FocusRootConfirmed({
    required this.confirmedRoot,
  });

  @override
  List<Object?> get props => [confirmedRoot];
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
  final int index;
  final Solution updatedSolution;

  const SolutionUpdated({
    required this.index,
    required this.updatedSolution,
  });

  @override
  List<Object?> get props => [index, updatedSolution];
}
class SolutionListResorted<T> extends IssueEvent {
  final List<Solution> items;
  final int oldIndex;
  final int newIndex;

  const SolutionListResorted({
    required this.items,
    required this.oldIndex,
    required this.newIndex,
  });

  @override
  List<Object?> get props => [items, oldIndex, newIndex];
}

final class FocusSolveConfirmed extends IssueEvent {
  final String confirmedSolve;

  const FocusSolveConfirmed({
    required this.confirmedSolve,
  });

  @override
  List<Object?> get props => [confirmedSolve];
}

/*

AS OF YET UNUSED DEMO EVENTS

*/
final class DemoIssueStarted extends IssueEvent {}
