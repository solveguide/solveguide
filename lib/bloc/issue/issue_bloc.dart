import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/models/hypothesis.dart';
import 'package:guide_solve/models/issue.dart';
import 'package:guide_solve/models/solution.dart';
import 'package:guide_solve/repositories/auth_repository.dart';
import 'package:guide_solve/repositories/issue_repository.dart';

part 'issue_event.dart';
part 'issue_state.dart';

class IssueBloc extends Bloc<IssueEvent, IssueState> {
  final IssueRepository issueRepository;
  final AuthRepository authRepository;
  IssueBloc(
    this.issueRepository,
    this.authRepository,
  ) : super(IssueInitial()) {
    on<IssuesFetched>(_fetchIssues);
    on<NewIssueCreated>(_addNewIssue);
    on<FocusIssueSelected>(_onFocusIssueSelected);
    on<IssueDeletionRequested>(_onIssueDeletionRequested);
    //Issue Solving Events
    on<NewHypothesisCreated>(_newHypothesisCreated);
    on<HypothesisListResorted>(_onHypothesisListResorted);
    on<HypothesisUpdated>(_onHypothesisUpdated);
    on<CreateSeparateIssueFromHypothesis>(_onCreateSeparateIssueFromHypothesis);
    on<FocusRootConfirmed>(_onFocusRootConfirmed);
    on<NewSolutionCreated>(_onNewSolutionCreated);
    on<SolutionListResorted>(_onSolutionListResorted);
    on<SolutionUpdated>(_onSolutionUpdated);
    on<FocusSolveConfirmed>(_focusSolveConfirmed);
    on<FocusSolveScopeSubmitted>(_onFocusSolveScopeSubmitted);
    //Solution Proving Events
    on<SolveProvenByOwner>(_onSolveProvenByOwner);
    on<SolveDisprovenByOwner>(_onSolveDisprovenByOwner);
  }

  Future<void> _fetchIssues(
    IssuesFetched event,
    Emitter<IssueState> emit,
  ) async {
    // Check if the current state is related to an issue being in focus
    // if (state is IssueInFocusInitial ||
    //     state is IssueInFocusRootIdentified ||
    //     state is IssueInFocusSolved) {
    //   // Return early to prevent fetching issues and changing the state
    //   return;
    // }

    emit(IssuesListLoading());
    try {
      // get userId from AuthBloc
      final userId = await authRepository.getUserUid();
      if (userId == null) {
        emit(const IssuesListFailure('User not authenticated'));
        return;
      }
      // Use getIssuesList for a one-time fetch
      final issuesList = await issueRepository.getIssueList(userId);
      emit(IssuesListSuccess(issueList: issuesList));
    } catch (error) {
      emit(IssuesListFailure(error.toString()));
    }
  }

  void _addNewIssue(
    NewIssueCreated event,
    Emitter<IssueState> emit,
  ) async {
    emit(IssuesListLoading());
    try {
      await issueRepository.addIssue(event.seedStatement, event.ownerId);
      final issuesList = await issueRepository.getIssueList(event.ownerId);
      emit(IssuesListSuccess(issueList: issuesList));
    } catch (error) {
      emit(IssuesListFailure(error.toString()));
    }
  }

  void _onIssueDeletionRequested(
    IssueDeletionRequested event,
    Emitter<IssueState> emit,
  ) async {
    emit(IssuesListLoading());
    try {
      await issueRepository.deleteIssue(event.issueId);
      final issuesList = await issueRepository.getIssueList(event.ownerId);
      emit(IssuesListSuccess(issueList: issuesList));
    } catch (error) {
      emit(IssuesListFailure(error.toString()));
    }
  }

  void _onFocusIssueSelected(
    FocusIssueSelected event,
    Emitter<IssueState> emit,
  ) async {
    try {
      final List<Issue> issuesList =
          await issueRepository.getIssueList(event.userId);
      final focusedIssue = issuesList.firstWhere(
        (issue) => issue.issueId == event.issueID,
      );
      issueRepository.setFocusIssue(focusedIssue);
      emit(IssueInFocusInitial(focusedIssue: focusedIssue));
    } catch (e) {
      emit(const IssuesListFailure("Issue not found"));
    }
  }

  void _newHypothesisCreated(
    NewHypothesisCreated event,
    Emitter<IssueState> emit,
  ) {
    final currentState = state;

    if (currentState is IssueInFocusInitial) {
      // Create a new hypothesis
      final newHypothesis = Hypothesis(desc: event.newHypothesis);

      // Create a copy of the current hypotheses list and add the new hypothesis at the top
      final updatedHypotheses =
          List<Hypothesis>.from(currentState.focusedIssue.hypotheses);
      updatedHypotheses.insert(0, newHypothesis);

      // Create a new focused issue with the updated hypotheses list
      final updatedIssue = currentState.focusedIssue.copyWith(
        hypotheses: updatedHypotheses,
      );

      // Emit the new state
      issueRepository.setFocusIssue(updatedIssue);
      emit(IssueInFocusInitial(focusedIssue: updatedIssue));
    } else {
      emit(const IssuesListFailure("No Issue Selected"));
    }
  }

  void _onHypothesisUpdated(
    HypothesisUpdated event,
    Emitter<IssueState> emit,
  ) {
    final currentState = state;

    if (currentState is IssueInFocusInitial) {
      // Create a copy of the current hypotheses list
      final updatedHypotheses =
          List<Hypothesis>.from(currentState.focusedIssue.hypotheses);

      // Remove the old hypothesis, add the new one at the top of the list
      updatedHypotheses.removeAt(event.index);
      updatedHypotheses.insert(0, event.updatedHypothesis);

      // Create a new focused issue with the updated hypotheses
      final updatedIssue = currentState.focusedIssue.copyWith(
        hypotheses: updatedHypotheses,
      );

      // Emit the new state
      try {
        issueRepository.setFocusIssue(updatedIssue);
        issueRepository.updateIssue(updatedIssue.issueId!, updatedIssue);
        emit(IssueInFocusInitial(focusedIssue: updatedIssue));
      } catch (e) {
        emit(IssuesListFailure(e.toString()));
      }
    }
  }

  Future<void> _onCreateSeparateIssueFromHypothesis(
    CreateSeparateIssueFromHypothesis event,
    Emitter<IssueState> emit,
  ) async {
    Issue? focusIssue = issueRepository.getFocusIssue();

    if (focusIssue == null) {
      emit(const IssuesListFailure(
          "An Error Occurred while spinning off your issue."));
    } else {
      String spinoffId = "";
      try {
        //update focus issue to db
        issueRepository.updateIssue(focusIssue.issueId!, focusIssue);

        //create a new spinoff issue in the db
        spinoffId = await issueRepository.addSpinoffIssue(
          focusIssue,
          event.hypothesis.desc,
          event.ownerId,
        );
      } catch (e) {
        emit(const IssuesListFailure(
            "Error occurred while spinning off the issue."));
      }
      try {
        Hypothesis updatedHypothesis = event.hypothesis.copyWith(
          isSpinoffIssue: true,
          spinoffIssueId: spinoffId,
        );
        List<Hypothesis> updatedHypotheses = focusIssue.hypotheses;
        updatedHypotheses.removeAt(event.index);
        updatedHypotheses.add(updatedHypothesis);

        Issue updatedIssue = focusIssue.copyWith(
          hypotheses: updatedHypotheses,
        );

        //update focus issue to db
        issueRepository.updateIssue(focusIssue.issueId!, updatedIssue);
        issueRepository.setFocusIssue(updatedIssue);
        emit(IssueInFocusInitial(focusedIssue: updatedIssue));
      } catch (e) {
        emit(IssuesListFailure(e.toString()));
      }
    }
  }

  void _onHypothesisListResorted(
    HypothesisListResorted event,
    Emitter<IssueState> emit,
  ) {
    final Issue? focusIssue = issueRepository.getFocusIssue();

    if (focusIssue == null) {
      emit(const IssuesListFailure("No Issue Selected"));
      return;
    }

    // Step 1: Create a copy of the list
    final List<Hypothesis> updatedItems = List.from(event.items);

    // Step 2: Remove the item at the old index and insert it at the new index
    final item = updatedItems.removeAt(event.oldIndex);

    int newIndex = event.newIndex;
    if (newIndex > event.oldIndex) {
      newIndex -= 1;
    }

    updatedItems.insert(newIndex, item);

    // Step 3: Update the Issue object with the new list
    final updatedIssue = focusIssue.copyWith(
      hypotheses: updatedItems,
    );

    // Step 4: Emit the new state with the updated issue
    issueRepository.updateIssue(focusIssue.issueId!, updatedIssue);
    issueRepository.setFocusIssue(updatedIssue);
    emit(IssueInFocusInitial(focusedIssue: updatedIssue));
  }

  void _onSolutionListResorted(
    SolutionListResorted event,
    Emitter<IssueState> emit,
  ) {
    final Issue? focusIssue = issueRepository.getFocusIssue();

    if (focusIssue == null) {
      emit(const IssuesListFailure("No Issue Selected"));
      return;
    }

    // Step 1: Create a copy of the list
    final List<Solution> updatedItems = List.from(event.items);

    // Step 2: Remove the item at the old index and insert it at the new index
    final item = updatedItems.removeAt(event.oldIndex);

    int newIndex = event.newIndex;
    if (newIndex > event.oldIndex) {
      newIndex -= 1;
    }

    updatedItems.insert(newIndex, item);

    // Step 3: Update the Issue object with the new list
    final updatedIssue = focusIssue.copyWith(
      solutions: updatedItems,
    );

    // Step 4: Emit the new state with the updated issue
    issueRepository.updateIssue(focusIssue.issueId!, updatedIssue);
    issueRepository.setFocusIssue(updatedIssue);
    emit(IssueInFocusRootIdentified(
        focusedIssue: updatedIssue, rootCause: updatedIssue.root));
  }

  void _onFocusRootConfirmed(
    FocusRootConfirmed event,
    Emitter<IssueState> emit,
  ) async {
    Issue? focusIssue = issueRepository.getFocusIssue();

    if (focusIssue == null) {
      emit(const IssuesListFailure("No Issue Selected"));
    } else {
      // Update the local copy of the issue
      Issue updatedIssue = focusIssue.copyWith(
        root: event.confirmedRoot,
        label: event.confirmedRoot,
      );
      issueRepository.setFocusIssue(updatedIssue);
      try {
        // Push the updated issue to Firebase
        await issueRepository.updateIssue(focusIssue.issueId!, updatedIssue);
        // Emit the updated state
        emit(IssueInFocusRootIdentified(
          focusedIssue: updatedIssue,
          rootCause: updatedIssue.root,
        ));
      } catch (error) {
        emit(IssuesListFailure("Failed to update issue in Firebase: $error"));
      }
    }
  }

  void _onNewSolutionCreated(
      NewSolutionCreated event, Emitter<IssueState> emit) {
    Issue? focusIssue = issueRepository.getFocusIssue();

    if (focusIssue == null) {
      emit(const IssuesListFailure("No Issue Selected"));
    } else {
      List<Solution> updatedSolutions = focusIssue.solutions;
      updatedSolutions.insert(
          0,
          Solution(
              desc: event.newSolution,
              assignedStakeholderUserId: focusIssue.ownerId));
      Issue updatedIssue = focusIssue.copyWith(
        solutions: updatedSolutions,
      );
      issueRepository.updateIssue(focusIssue.issueId!, updatedIssue);
      issueRepository.setFocusIssue(updatedIssue);
      emit(IssueInFocusRootIdentified(
        focusedIssue: updatedIssue,
        rootCause: updatedIssue.root,
      ));
    }
  }

  void _onSolutionUpdated(SolutionUpdated event, Emitter<IssueState> emit) {
    final currentState = state;

    if (currentState is IssueInFocusRootIdentified) {
      // Create a copy of the current hypotheses list
      final updatedSolutions =
          List<Solution>.from(currentState.focusedIssue.solutions);

      // Update the hypothesis at the given index
      updatedSolutions[event.index] = event.updatedSolution;

      // Move the updated hypothesis to the top of the list
      final solution = updatedSolutions.removeAt(event.index);
      updatedSolutions.insert(0, solution);

      // Create a new focused issue with the updated hypotheses
      final updatedIssue = currentState.focusedIssue.copyWith(
        solutions: updatedSolutions,
      );
      issueRepository.updateIssue(updatedIssue.issueId!, updatedIssue);
      issueRepository.setFocusIssue(updatedIssue);
      // Emit the new state
      emit(IssueInFocusRootIdentified(
          rootCause: updatedIssue.root, focusedIssue: updatedIssue));
    }
  }

  void _focusSolveConfirmed(
      FocusSolveConfirmed event, Emitter<IssueState> emit) async {
    Issue? focusIssue = issueRepository.getFocusIssue();

    if (focusIssue == null) {
      emit(const IssuesListFailure("No Issue Selected"));
    } else {
      Issue updatedIssue = focusIssue.copyWith(
        solve: event.confirmedSolve,
      );
      await issueRepository.updateIssue(focusIssue.issueId!, updatedIssue);
      issueRepository.setFocusIssue(updatedIssue);
      emit(IssueInFocusSolutionIdentified(
          focusedIssue: updatedIssue, solution: event.confirmedSolve));
    }
  }

  void _onFocusSolveScopeSubmitted(
      FocusSolveScopeSubmitted event, Emitter<IssueState> emit) async {
    Issue? focusIssue = issueRepository.getFocusIssue();

    if (focusIssue == null) {
      emit(const IssuesListFailure("No Issue Selected"));
    } else {
      try {
        List<Solution> updatedSolution = List.from(focusIssue.solutions);
        updatedSolution.removeAt(0);
        updatedSolution.insert(0, event.confirmedSolve);
        Issue updatedIssue = focusIssue.copyWith(
          solve: event.confirmedSolve.desc,
          solutions: updatedSolution,
        );
        await issueRepository.updateIssue(focusIssue.issueId!, updatedIssue);
        issueRepository.setFocusIssue(updatedIssue);
        emit(IssueInFocusSolved(focusedIssue: updatedIssue));
      } catch (e) {
        emit(IssuesListFailure(e.toString()));
      }
    }
  }

  void _onSolveProvenByOwner(
    SolveProvenByOwner event,
    Emitter<IssueState> emit,
  ) async {
// Find the solution that matches the solve
    Solution? provenSolve;

    try {
      provenSolve = event.issue.solutions.firstWhere(
        (solution) => solution.desc == event.issue.solve,
      );
    } catch (e) {
      emit(IssuesListFailure("Could not find matching Solution: $e"));
      return;
    }
// Check that the current UserId matches the assignedStakeholderUserId
    if (provenSolve.assignedStakeholderUserId != event.userId) {
      emit(const IssuesListFailure(
          "You are not the person assigned to this solve and cannot mark it proven."));
      return;
    }

// Add the issueId to the list of provenIssueIds on that solution
    List<String> updatedProvenIssueIds =
        List.from(provenSolve.provenIssueIds ?? [])..add(event.issue.issueId!);
    Solution updatedProvenSolve =
        provenSolve.copyWith(provenIssueIds: updatedProvenIssueIds);
    event.issue.solutions.removeAt(0);
    final updatedSolutions = List<Solution>.from(event.issue.solutions);
    updatedSolutions.insert(0, updatedProvenSolve);

    Issue updatedIssue = event.issue.copyWith(
      solutions: updatedSolutions,
      proven: true,
    );
    await issueRepository.updateIssue(updatedIssue.issueId!, updatedIssue);

    final issuesList = await issueRepository.getIssueList(event.userId);
    emit(IssuesListSuccess(issueList: issuesList));
  }

  void _onSolveDisprovenByOwner(
    SolveDisprovenByOwner event,
    Emitter<IssueState> emit,
  ) async {
// Find the solution that matches the solve
    Solution? disprovenSolve;

    try {
      disprovenSolve = event.issue.solutions.firstWhere(
        (solution) => solution.desc == event.issue.solve,
      );
    } catch (e) {
      emit(IssuesListFailure("Could not find matching Solution: $e"));
      return;
    }
// Check that the current UserId matches the assignedStakeholderUserId
    if (disprovenSolve.assignedStakeholderUserId != event.userId) {
      emit(const IssuesListFailure(
          "You are not the person assigned to this solve and cannot mark it disproven."));
      return;
    }

// Add the issueId to the list of provenIssueIds on that solution
    List<String> updatedDisrovenIssueIds =
        List.from(disprovenSolve.disprovenIssueIds ?? [])
          ..add(event.issue.issueId!);
    Solution updatedDisprovenSolve =
        disprovenSolve.copyWith(provenIssueIds: updatedDisrovenIssueIds);
    event.issue.solutions.removeAt(0);
    final updatedSolutions = List<Solution>.from(event.issue.solutions);
    updatedSolutions.add(updatedDisprovenSolve);

    Issue updatedIssue = event.issue.copyWith(
      solutions: updatedSolutions,
      solve: "",
      proven: false,
    );
    await issueRepository.updateIssue(updatedIssue.issueId!, updatedIssue);

    final issuesList = await issueRepository.getIssueList(event.userId);
    emit(IssuesListSuccess(issueList: issuesList));
  }
}
