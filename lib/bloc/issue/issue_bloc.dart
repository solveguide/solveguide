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
  StreamSubscription<Issue>? _focusedIssueSubscription;
  Issue? _focusedIssue;
  String? _currentIssueId;

  IssueBloc(
    this.issueRepository,
    this.authRepository,
  ) : super(IssueInitial()) {
    on<IssuesFetched>(_fetchIssues);
    on<NewIssueCreated>(_addNewIssue);
    on<FocusIssueSelected>(_onFocusIssueSelected);
    on<FocusedIssueUpdated>(_onFocusedIssueUpdated);
    on<IssueDeletionRequested>(_onIssueDeletionRequested);
    //Issue Solving Events
    on<NewHypothesisCreated>(_newHypothesisCreated);
    on<HypothesisUpdated>(_onHypothesisUpdated);
    on<CreateSeparateIssueFromHypothesis>(_onCreateSeparateIssueFromHypothesis);
    on<FocusRootConfirmed>(_onFocusRootConfirmed);
    on<NewSolutionCreated>(_onNewSolutionCreated);
    on<SolutionUpdated>(_onSolutionUpdated);
    on<FocusSolveConfirmed>(_focusSolveConfirmed);
    //on<FocusSolveScopeSubmitted>(_onFocusSolveScopeSubmitted);
    //Solution Proving Events
    //on<SolveProvenByOwner>(_onSolveProvenByOwner);
    //on<SolveDisprovenByOwner>(_onSolveDisprovenByOwner);
  }

  Issue? get focusedIssue => _focusedIssue;

  Future<void> _fetchIssues(
    IssuesFetched event,
    Emitter<IssueState> emit,
  ) async {
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
      // get userId from AuthBloc
      final userId = await authRepository.getUserUid();
      if (userId == null) {
        emit(const IssuesListFailure('User not authenticated'));
        return;
      }
      await issueRepository.addIssue(event.seedStatement, userId);
      final issuesList = await issueRepository.getIssueList(userId);
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
      // get userId from AuthBloc
      final userId = await authRepository.getUserUid();
      if (userId == null) {
        emit(const IssuesListFailure('User not authenticated'));
        return;
      }
      await issueRepository.deleteIssue(event.issueId);
      final issuesList = await issueRepository.getIssueList(userId);
      emit(IssuesListSuccess(issueList: issuesList));
    } catch (error) {
      emit(IssuesListFailure(error.toString()));
    }
  }

  void _onFocusIssueSelected(
    FocusIssueSelected event,
    Emitter<IssueState> emit,
  ) async {
    // Cancel any existing subscription
    await _focusedIssueSubscription?.cancel();

    _currentIssueId = event.issueID;

    // Start listening to the focused issue stream
    _focusedIssueSubscription =
        issueRepository.getFocusedIssueStream(event.issueID).listen((issue) {
      // Store the latest issue from the stream
      _focusedIssue = issue;
      // Emit states based on the issue's data
      add(FocusedIssueUpdated(issue));
    }, onError: (error) {
      emit(IssuesListFailure(error.toString()));
    });
  }

  // Handle the new event when the focused issue is updated
  void _onFocusedIssueUpdated(
    FocusedIssueUpdated event,
    Emitter<IssueState> emit,
  ) async {
    final issue = event.focusedIssue;
    List<Hypothesis> hypotheses =
        await issueRepository.getHypotheses(issue.issueId!).first;
    List<Solution> solutions =
        await issueRepository.getSolutions(issue.issueId!).first;

    IssueProcessStage stage;

    if (issue.root.isEmpty && hypotheses.length < 2) {
      stage = IssueProcessStage.wideningHypotheses;
    } else if (issue.root.isEmpty && hypotheses.length >= 2) {
      stage = IssueProcessStage.narrowingToRootCause;
    } else if (issue.solve.isEmpty && solutions.length < 2) {
      stage = IssueProcessStage.wideningSolutions;
    } else if (issue.solve.isEmpty && solutions.length >= 2) {
      stage = IssueProcessStage.narrowingToSolve;
    } else if (!issue.proven) {
      stage = IssueProcessStage.scopingSolve;
    } else {
      stage = IssueProcessStage.solveSummaryReview;
    }

    emit(IssueProcessState(stage));
  }

  void _newHypothesisCreated(
    NewHypothesisCreated event,
    Emitter<IssueState> emit,
  ) async {
    // Get the current issue ID
    final issueId =
        _currentIssueId; // You'll need to store the current issue ID in the Bloc

    if (issueId == null) {
      emit(const IssuesListFailure("No Issue Selected"));
      return;
    }

    // Get userId from AuthRepository
    final userId = await authRepository.getUserUid();
    if (userId == null) {
      emit(const IssuesListFailure('User not authenticated'));
      return;
    }

    try {
      // Add the new hypothesis using the repository
      await issueRepository.addHypothesis(issueId, event.newHypothesis, userId);
      // No need to emit a new state; the UI will update via the stream
    } catch (error) {
      emit(IssuesListFailure(error.toString()));
    }
  }

  void _onHypothesisUpdated(
    HypothesisUpdated event,
    Emitter<IssueState> emit,
  ) async {
    // Get the current issue ID
    final issueId = _currentIssueId;

    if (issueId == null) {
      emit(const IssuesListFailure("No Issue Selected"));
      return;
    }
//TODO: use copyWith() to pull the existing hypothesis and add the new desc. When no votes are present.
    try {
      // Update the hypothesis using the repository
      await issueRepository.updateHypothesis(
        issueId,
        Hypothesis(
          hypothesisId: event.hypothesisId,
          desc: event.updatedDescription,
          lastUpdatedTimestamp: DateTime.now(),
          // Include other necessary fields
        ),
      );
      // No need to emit a new state; the UI will update via the stream
    } catch (error) {
      emit(IssuesListFailure(error.toString()));
    }
  }

  Future<void> _onCreateSeparateIssueFromHypothesis(
    CreateSeparateIssueFromHypothesis event,
    Emitter<IssueState> emit,
  ) async {
    final issueId = _currentIssueId;

    if (issueId == null) {
      emit(const IssuesListFailure("No Issue Selected"));
      return;
    }
    final Issue? originalIssue = await issueRepository.getIssueById(issueId);

    if (originalIssue == null) {
      emit(const IssuesListFailure("Selected Issue is Null"));
      return;
    }

    try {
      // Get userId from AuthRepository
      final userId = await authRepository.getUserUid();
      if (userId == null) {
        emit(const IssuesListFailure('User not authenticated'));
        return;
      }

      // Fetch the hypothesis from the repository
      final hypothesis =
          await issueRepository.getHypothesisById(issueId, event.hypothesisId);

      if (hypothesis == null) {
        emit(const IssuesListFailure("Hypothesis not found"));
        return;
      }

      // Create a new issue as a spinoff
      final spinoffId = await issueRepository.addSpinoffIssue(
        originalIssue,
        hypothesis.desc,
        userId,
      );

      // Update the original hypothesis to mark it as a spinoff
      final updatedHypothesis = hypothesis.copyWith(
        isSpinoffIssue: true,
        spinoffIssueId: spinoffId,
      );

      await issueRepository.updateHypothesis(issueId, updatedHypothesis);
      // No need to emit a new state; the UI will update via the stream
    } catch (error) {
      emit(IssuesListFailure(error.toString()));
    }
  }

  void _onFocusRootConfirmed(
    FocusRootConfirmed event,
    Emitter<IssueState> emit,
  ) async {
    final issueId = _currentIssueId;

    if (issueId == null) {
      emit(const IssuesListFailure("No Issue Selected"));
      return;
    }

    try {
      // Update the issue's root in Firestore
      await issueRepository.updateIssueRoot(
          issueId, event.confirmedRootHypothesisId);
      // No need to emit a new state; the UI will update via the stream
    } catch (error) {
      emit(IssuesListFailure("Failed to update issue in Firebase: $error"));
    }
  }

  void _onNewSolutionCreated(
    NewSolutionCreated event,
    Emitter<IssueState> emit,
  ) async {
    final issueId = _currentIssueId;

    if (issueId == null) {
      emit(const IssuesListFailure("No Issue Selected"));
      return;
    }

    // Get userId from AuthRepository
    final userId = await authRepository.getUserUid();
    if (userId == null) {
      emit(const IssuesListFailure('User not authenticated'));
      return;
    }

    try {
      // Add the new solution using the repository
      await issueRepository.addSolution(issueId, event.newSolution, userId);
      // No need to emit a new state; the UI will update via the stream
    } catch (error) {
      emit(IssuesListFailure(error.toString()));
    }
  }

  void _onSolutionUpdated(
    SolutionUpdated event,
    Emitter<IssueState> emit,
  ) async {
    final issueId = _currentIssueId;

    if (issueId == null) {
      emit(const IssuesListFailure("No Issue Selected"));
      return;
    }

    try {
      // Update the solution using the repository
      await issueRepository.updateSolution(
        issueId,
        //TODO: use copyWith() to pull the existing solution and add the new desc. When no votes are present.
        Solution(
          solutionId: event.solutionId,
          desc: event.updatedDescription,
          lastUpdatedTimestamp: DateTime.now(),
          // Include other necessary fields
        ),
      );
      // No need to emit a new state; the UI will update via the stream
    } catch (error) {
      emit(IssuesListFailure(error.toString()));
    }
  }

  void _focusSolveConfirmed(
    FocusSolveConfirmed event,
    Emitter<IssueState> emit,
  ) async {
    final issueId = _currentIssueId;

    if (issueId == null) {
      emit(const IssuesListFailure("No Issue Selected"));
      return;
    }

    try {
      // Update the issue's solve in Firestore
      await issueRepository.updateIssueSolve(issueId, event.solutionId);
      // No need to emit a new state; the UI will update via the stream
    } catch (error) {
      emit(IssuesListFailure("Failed to update issue in Firebase: $error"));
    }
  }

/*

void _onFocusSolveScopeSubmitted(
  FocusSolveScopeSubmitted event,
  Emitter<IssueState> emit,
) async {
  final issueId = _currentIssueId;

  if (issueId == null) {
    emit(const IssuesListFailure("No Issue Selected"));
    return;
  }

  try {
    // Assuming scope details are included in the event or need to be updated in the solution
    // Update the solution with the scope details
    // You might need to define what scope submission involves
    // For example:

    // Fetch the solution
    final solution = await issueRepository.getSolutionById(issueId, event.solutionId);

    if (solution == null) {
      emit(const IssuesListFailure("Solution not found"));
      return;
    }

    // Update the solution with scope details (assuming you have such a field)
    final updatedSolution = solution.copyWith(
      scopeDetails: event.scopeDetails, // If applicable
    );

    await issueRepository.updateSolution(issueId, updatedSolution);

    // Update the issue's state if necessary
    // For example, mark it as in the "Defining Solve" stage

    // No need to emit a new state; the UI will update via the stream
  } catch (e) {
    emit(IssuesListFailure(e.toString()));
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
    //get userId from AuthBloc
    final userId = await authRepository.getUserUid();
    if (userId == null) {
      emit(const IssuesListFailure('User not authenticated'));
      return;
    }
// Check that the current UserId matches the assignedStakeholderUserId
    if (provenSolve.assignedStakeholderUserId != userId) {
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

    final issuesList = await issueRepository.getIssueList(userId);
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
//get userId from AuthBloc
    final userId = await authRepository.getUserUid();
    if (userId == null) {
      emit(const IssuesListFailure('User not authenticated'));
      return;
    }
// Check that the current UserId matches the assignedStakeholderUserId
    if (disprovenSolve.assignedStakeholderUserId != userId) {
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

    final issuesList = await issueRepository.getIssueList(userId);
    emit(IssuesListSuccess(issueList: issuesList));
  }

  */
  @override
  Future<void> close() {
    _focusedIssueSubscription?.cancel();
    return super.close();
  }
}
