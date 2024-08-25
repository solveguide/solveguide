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

class HypothesisUpdated extends IssueEvent {
  final int index;
  final Hypothesis updatedHypothesis;

  HypothesisUpdated({
    required this.index,
    required this.updatedHypothesis,
  });
}

class CreateSeparateIssueFromHypothesis extends IssueEvent {
  final Hypothesis hypothesis;
  final bool newIssuePrioritized;
  final String ownerId;

  CreateSeparateIssueFromHypothesis({
    required this.hypothesis,
    required this.newIssuePrioritized,
    required this.ownerId,
  });
}

class ListResorted<T> extends IssueEvent {
  final List<T> items;
  final int oldIndex;
  final int newIndex;

  ListResorted({
    required this.items,
    required this.oldIndex,
    required this.newIndex,
  });
}

final class FocusRootConfirmed extends IssueEvent {
  final String confirmedRoot;

  FocusRootConfirmed({
    required this.confirmedRoot,
  });
}

final class NewSolutionCreated extends IssueEvent {
  final String newSolution;

  NewSolutionCreated({
    required this.newSolution,
  });
}

final class FocusSolveConfirmed extends IssueEvent {
  final String confirmedSolve;

  FocusSolveConfirmed({
    required this.confirmedSolve,
  });
}

/*

AS OF YET UNUSED DEMO EVENTS

*/
final class DemoIssueStarted extends IssueEvent {}
