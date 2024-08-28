import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/models/hypothesis.dart';
import 'package:guide_solve/models/issue.dart';
import 'package:guide_solve/models/solution.dart';
import 'package:guide_solve/repositories/issue_repository.dart';

part 'issue_event.dart';
part 'issue_state.dart';

class IssueBloc extends Bloc<IssueEvent, IssueState> {
  final IssueRepository issueRepository;
  IssueBloc(this.issueRepository) : super(IssueInitial()) {
    on<IssuesFetched>(_fetchIssues);
    on<NewIssueCreated>(_addNewIssue);
    on<FocusIssueSelected>(_onFocusIssueSelected);
    //Issue Solving Events
    on<NewHypothesisCreated>(_newHypothesisCreated);
    on<ListResorted>(_onListResorted);
    on<HypothesisUpdated>(_onHypothesisUpdated);
    on<CreateSeparateIssueFromHypothesis>(_onCreateSeparateIssueFromHypothesis);
    on<FocusRootConfirmed>(_onFocusRootConfirmed);
    on<NewSolutionCreated>(_onNewSolutionCreated);
    on<FocusSolveConfirmed>(_focusSolveConfirmed);
    on<SolutionUpdated>(_onSolutionUpdated);
    
  }

  void _fetchIssues(
    IssuesFetched event,
    Emitter<IssueState> emit,
  ) async {
    emit(IssuesListLoading());
    try {
      await emit.forEach<List<Issue>>(
        issueRepository.getIssuesStream(event.userId),
        onData: (issuesList) {
          if (issuesList.isEmpty) {
            return IssuesListFailure(
                "Congratulations, you have no issues."); // Custom state for empty list
          } else {
            return IssuesListSuccess(issueList: issuesList);
          }
        },
        onError: (error, stackTrace) {
          return IssuesListFailure(error.toString());
        },
      );
    } catch (error) {
      emit(IssuesListFailure(error.toString()));
    }
  }

  void _addNewIssue(
    NewIssueCreated event,
    Emitter<IssueState> emit,
  ) async {
    try {
      issueRepository.addIssue(event.seedStatement, event.ownerId);
      emit(IssueInitial());
    } catch (error) {
      emit(IssuesListFailure(error.toString()));
    }
  }

  void _onFocusIssueSelected(
    FocusIssueSelected event,
    Emitter<IssueState> emit,
  ) {
    if (state is IssuesListSuccess) {
      final issuesList = (state as IssuesListSuccess).issueList;
      try {
        // Assuming Issue has a unique 'id' field
        final focusedIssue = issuesList.firstWhere(
          (issue) => issue.issueId == event.issueID,
        );
        issueRepository.setFocusIssue(focusedIssue);
        emit(IssueInFocusInitial(focusedIssue: focusedIssue));
      } catch (e) {
        emit(IssuesListFailure("Issue not found"));
      }
    } else {
      emit(IssuesListFailure("Issues not loaded"));
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
      emit(IssueInFocusInitial(focusedIssue: updatedIssue));
    } else {
      emit(IssuesListFailure("No Issue Selected"));
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

      // Update the hypothesis at the given index
      updatedHypotheses[event.index] = event.updatedHypothesis;

      // Move the updated hypothesis to the top of the list
      final hypothesis = updatedHypotheses.removeAt(event.index);
      updatedHypotheses.insert(0, hypothesis);

      // Create a new focused issue with the updated hypotheses
      final updatedIssue = currentState.focusedIssue.copyWith(
        hypotheses: updatedHypotheses,
      );

      // Emit the new state
      emit(IssueInFocusInitial(focusedIssue: updatedIssue));
    }
  }

  void _onCreateSeparateIssueFromHypothesis(
    CreateSeparateIssueFromHypothesis event,
    Emitter<IssueState> emit,
  ) async {
    Issue? focusIssue = issueRepository.getFocusIssue();

    if (focusIssue == null) {
      emit(IssuesListFailure(
          "An Error Occurred while spinning off your issue."));
    } else {
      try {
        String spinoffId;
        try {
          //update focus issue to db
          issueRepository.updateIssue(focusIssue.issueId!, focusIssue);

          //create a new spinoff issue in the db
          spinoffId = await issueRepository.addSpinoffIssue(
            focusIssue,
            event.hypothesis.desc,
            event.ownerId,
          );
          event.hypothesis.isSpinoffIssue = true;
          event.hypothesis.spinoffIssueId = spinoffId;

          emit(IssueInFocusInitial(focusedIssue: focusIssue));
        } catch (e) {
          emit(IssuesListFailure(
              "Error occurred while spinning off the issue."));
        }
      } catch (e) {
        emit(IssuesListFailure("Issue not found"));
      }
    }
  }

  void _onListResorted<T>(
    ListResorted<T> event,
    Emitter<IssueState> emit,
  ) {
    Issue? focusIssue = issueRepository.getFocusIssue();

    if (focusIssue == null) {
      emit(IssuesListFailure("No Issue Selected"));
    } else {
      // Create a mutable copy of newIndex
      int newIndex = event.newIndex;

      if (newIndex > event.oldIndex) {
        newIndex -= 1;
      }

      final item = event.items.removeAt(event.oldIndex);
      event.items.insert(newIndex, item);

      emit(IssueInFocusInitial(focusedIssue: focusIssue));
    }
  }

  void _onFocusRootConfirmed(
    FocusRootConfirmed event,
    Emitter<IssueState> emit,
  ) async {
    Issue? focusIssue = issueRepository.getFocusIssue();

    if (focusIssue == null) {
      emit(IssuesListFailure("No Issue Selected"));
    } else {
      // Update the local copy of the issue
      focusIssue = focusIssue.copyWith(
        root: event.confirmedRoot,
        label: event.confirmedRoot,
      );

      try {
        // Push the updated issue to Firebase
        await issueRepository.updateIssue(focusIssue.issueId!, focusIssue);

        // Emit the updated state
        emit(IssueInFocusRootIdentified(
          focusedIssue: focusIssue,
          rootCause: event.confirmedRoot,
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
      emit(IssuesListFailure("No Issue Selected"));
    } else {
      focusIssue.solutions.insert(
        0,
        Solution(desc: event.newSolution),
      );
      emit(IssueInFocusRootIdentified(
        focusedIssue: focusIssue,
        rootCause: focusIssue.root,
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

      // Emit the new state
      emit(IssueInFocusRootIdentified(rootCause: updatedIssue.root, focusedIssue: updatedIssue));
    }
  }

  void _focusSolveConfirmed(
      FocusSolveConfirmed event, Emitter<IssueState> emit) {
    Issue? focusIssue = issueRepository.getFocusIssue();

    if (focusIssue == null) {
      emit(IssuesListFailure("No Issue Selected"));
    } else {
      focusIssue.solve = event.confirmedSolve;
      emit(IssueInFocusSolved(focusedIssue: focusIssue));
    }
  }

  
}
