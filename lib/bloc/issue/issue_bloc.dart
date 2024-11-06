import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/models/fact.dart';
import 'package:guide_solve/models/hypothesis.dart';
import 'package:guide_solve/models/issue.dart';
import 'package:guide_solve/models/solution.dart';
import 'package:guide_solve/repositories/auth_repository.dart';
import 'package:guide_solve/repositories/issue_repository.dart';

part 'issue_event.dart';
part 'issue_state.dart';

class IssueBloc extends Bloc<IssueEvent, IssueState> {
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
    on<HypothesisVoteSubmitted>(_onHypothesisVoteSubmitted);
    on<FocusRootConfirmed>(_onFocusRootConfirmed);
    on<NewSolutionCreated>(_onNewSolutionCreated);
    on<SolutionUpdated>(_onSolutionUpdated);
    on<FocusSolveConfirmed>(_focusSolveConfirmed);
    on<NewFactCreated>(_onNewFactCreated);
    on<FocusIssueNavigationRequested>(_onFocusIssueNavigationRequested);
    on<AddUserToIssueEvent>(_onAddUserToIssueEvent);
    //on<FocusSolveScopeSubmitted>(_onFocusSolveScopeSubmitted);
    //Solution Proving Events
    //on<SolveProvenByOwner>(_onSolveProvenByOwner);
    //on<SolveDisprovenByOwner>(_onSolveDisprovenByOwner);
  }

  final IssueRepository issueRepository;
  final AuthRepository authRepository;
  Stream<Issue>? _focusedIssueStream;
  Stream<List<Hypothesis>>? _hypothesesStream;
  Stream<List<Solution>>? _solutionsStream;
  Stream<List<Fact>>? _factsStream;
  Issue? focusedIssue;

  String? _currentIssueId;
  String? _currentUserId;

  String? get currentUserId => _currentUserId;
  String? get currentIssueId => _currentIssueId;

  Stream<Issue>? get focusedIssueStream => _focusedIssueStream;
  Stream<List<Hypothesis>>? get hypothesesStream => _hypothesesStream;
  Stream<List<Solution>>? get solutionsStream => _solutionsStream;
  Stream<List<Fact>>? get factsStream => _factsStream;

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
      _currentUserId = userId;
      // Use getIssuesList for a one-time fetch
      final issuesList = await issueRepository.getIssueList(userId);
      emit(IssuesListSuccess(issueList: issuesList));
    } catch (error) {
      emit(IssuesListFailure(error.toString()));
    }
  }

  Future<void> _addNewIssue(
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

  Future<void> _onIssueDeletionRequested(
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

  Future<void> _onFocusIssueSelected(
    FocusIssueSelected event,
    Emitter<IssueState> emit,
  ) async {
    _currentIssueId = event.issueId;

    _focusedIssueStream =
        await issueRepository.getFocusedIssueStream(event.issueId);
    _hypothesesStream = await issueRepository.getHypotheses(event.issueId);
    _solutionsStream = await issueRepository.getSolutions(event.issueId);
    _factsStream = await issueRepository.getFacts(event.issueId);

    focusedIssue = await issueRepository.getLatestValue(_focusedIssueStream!);

    emit(
      IssueProcessState(
        stage: IssueProcessStage.wideningHypotheses,
        hypothesesStream: _hypothesesStream,
        solutionsStream: _solutionsStream,
      ),
    );
  }

  // Handle the new event when the focused issue is updated
  Future<void> _onFocusedIssueUpdated(
    FocusedIssueUpdated event,
    Emitter<IssueState> emit,
  ) async {
    final issue = event.focusedIssue;

    // Get the appropriate streams for the current issue
    final hypothesesStream = issueRepository.getHypotheses(issue.issueId!);
    final solutionsStream = issueRepository.getSolutions(issue.issueId!);

    final hypotheses = await hypothesesStream.first;
    final solutions = await solutionsStream.first;

    final perspective =
        issue.perspective(_currentUserId!, hypotheses, solutions);

    IssueProcessStage stage;

    if (issue.root.isEmpty && (await hypothesesStream.first).length < 4) {
      stage = IssueProcessStage.wideningHypotheses;
      emit(
        IssueProcessState(
          stage: stage,
          hypothesesStream: hypothesesStream,
          solutionsStream: solutionsStream,
          perspective: perspective,
        ),
      );
    } else if (issue.root.isEmpty) {
      stage = IssueProcessStage.narrowingToRootCause;
      emit(
        IssueProcessState(
          stage: stage,
          hypothesesStream: hypothesesStream,
          solutionsStream: solutionsStream,
          perspective: perspective,
        ),
      );
    } else if (issue.solve.isEmpty &&
        (await solutionsStream.first).length < 4) {
      stage = IssueProcessStage.wideningSolutions;
      emit(
        IssueProcessState(
          stage: stage,
          hypothesesStream: hypothesesStream,
          solutionsStream: solutionsStream,
          perspective: perspective,
        ),
      );
    } else if (issue.solve.isEmpty) {
      stage = IssueProcessStage.narrowingToSolve;
      emit(
        IssueProcessState(
          stage: stage,
          hypothesesStream: hypothesesStream,
          solutionsStream: solutionsStream,
          perspective: perspective,
        ),
      );
    } else {
      // Handle other stages and emit the appropriate state
      emit(
        const IssueProcessState(stage: IssueProcessStage.solveSummaryReview),
      );
    }
  }

  FutureOr<void> _onFocusIssueNavigationRequested(
    FocusIssueNavigationRequested event,
    Emitter<IssueState> emit,
  ) async {
    final stage = event.stage;

    _focusedIssueStream =
        await issueRepository.getFocusedIssueStream(focusedIssue!.issueId!);
    _hypothesesStream =
        await issueRepository.getHypotheses(focusedIssue!.issueId!);
    _solutionsStream =
        await issueRepository.getSolutions(focusedIssue!.issueId!);
    _factsStream = await issueRepository.getFacts(focusedIssue!.issueId!);

    focusedIssue = await issueRepository.getLatestValue(_focusedIssueStream!);

    emit(
      IssueProcessState(
        stage: stage,
      ),
    );
  }

  Future<void> _newHypothesisCreated(
    NewHypothesisCreated event,
    Emitter<IssueState> emit,
  ) async {
    // Get the current issue ID
    final issueId = _currentIssueId;

    if (issueId == null) {
      emit(const IssuesListFailure('No Issue Selected'));
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

  Future<void> _onHypothesisUpdated(
    HypothesisUpdated event,
    Emitter<IssueState> emit,
  ) async {
    // Get the current issue ID
    final issueId = _currentIssueId;

    if (issueId == null) {
      emit(const IssuesListFailure('No Issue Selected'));
      return;
    }
    try {
      // Update the hypothesis using the repository
      await issueRepository.updateHypothesis(
        issueId,
        Hypothesis(
          ownerId: _currentIssueId!,
          hypothesisId: event.hypothesisId,
          desc: event.updatedDescription,
          lastUpdatedTimestamp: DateTime.now(),
          createdTimestamp: DateTime.now(),
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
      emit(const IssuesListFailure('No Issue Selected'));
      return;
    }
    final originalIssue = await issueRepository.getIssueById(issueId);

    if (originalIssue == null) {
      emit(const IssuesListFailure('Selected Issue is Null'));
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
        emit(const IssuesListFailure('Hypothesis not found'));
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

  Future<void> _onHypothesisVoteSubmitted(
    HypothesisVoteSubmitted event,
    Emitter<IssueState> emit,
  ) async {
    try {
      // Ensure the Bloc state is of type IssueProcessState
      if (state is! IssueProcessState) return;
      final currentState = state as IssueProcessState;

      // Ensure current issue ID and hypothesis are available
      if (_currentIssueId == null)
        throw Exception('_currentIssueId is not set');
      final currentHypothesis = await issueRepository.getHypothesisById(
          _currentIssueId!, event.hypothesisId);
      if (currentHypothesis == null) throw Exception('Hypothesis not found.');

      // Update the votes map with the new vote
      final updatedVotes =
          Map<String, HypothesisVote>.from(currentHypothesis.votes)
            ..[_currentUserId!] = event.voteValue;

      // Create a new hypothesis object with updated votes
      final updatedHypothesis = currentHypothesis.copyWith(votes: updatedVotes);

      // Update Firestore with the new hypothesis state
      await issueRepository.updateHypothesis(
          _currentIssueId!, updatedHypothesis);

      // Re-emit the IssueProcessState to trigger UI updates
      emit(
        IssueProcessState(
          stage: currentState.stage,
          hypothesesStream: _hypothesesStream,
          solutionsStream: _solutionsStream,
          perspective: currentState.perspective,
        ),
      );

      // Handle navigation if necessary after updating the vote
      if (event.voteValue == HypothesisVote.root) {
        add(FocusIssueNavigationRequested(
            stage: IssueProcessStage.narrowingToRootCause));
      }
    } catch (e) {
      // Handle errors and emit failure state if necessary
      emit(IssuesListFailure('Failed to submit vote: ${e.toString()}'));
    }
  }

  Future<void> _onFocusRootConfirmed(
    FocusRootConfirmed event,
    Emitter<IssueState> emit,
  ) async {
    final issueId = _currentIssueId;

    if (issueId == null) {
      emit(const IssuesListFailure('No Issue Selected'));
      return;
    }

    try {
      // Update the issue's root in Firestore
      await issueRepository.updateIssueRoot(
        issueId,
        event.confirmedRootHypothesisId,
      );
      // No need to emit a new state; the UI will update via the stream
    } catch (error) {
      emit(IssuesListFailure('Failed to update issue in Firebase: $error'));
    }
  }

  Future<void> _onNewSolutionCreated(
    NewSolutionCreated event,
    Emitter<IssueState> emit,
  ) async {
    final issueId = _currentIssueId;

    if (issueId == null) {
      emit(const IssuesListFailure('No Issue Selected'));
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

  Future<void> _onSolutionUpdated(
    SolutionUpdated event,
    Emitter<IssueState> emit,
  ) async {
    final issueId = _currentIssueId;

    if (issueId == null) {
      emit(const IssuesListFailure('No Issue Selected'));
      return;
    }

    try {
      // Update the solution using the repository
      await issueRepository.updateSolution(
        issueId,
        Solution(
          ownerId: _currentIssueId!,
          solutionId: event.solutionId,
          desc: event.updatedDescription,
          lastUpdatedTimestamp: DateTime.now(),
          createdTimestamp: DateTime.now(),
        ),
      );
      // No need to emit a new state; the UI will update via the stream
    } catch (error) {
      emit(IssuesListFailure(error.toString()));
    }
  }

  Future<void> _focusSolveConfirmed(
    FocusSolveConfirmed event,
    Emitter<IssueState> emit,
  ) async {
    final issueId = _currentIssueId;

    if (issueId == null) {
      emit(const IssuesListFailure('No Issue Selected'));
      return;
    }

    try {
      // Update the issue's solve in Firestore
      await issueRepository.updateIssueSolve(issueId, event.solutionId);
      // No need to emit a new state; the UI will update via the stream
    } catch (error) {
      emit(IssuesListFailure('Failed to update issue in Firebase: $error'));
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
    final solution = await issueRepository.getSolutionById(
    issueId, 
    event.solutionId,
    );

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
          
    "You are not the person assigned to this solve and cannot mark it proven.",
        //  ),
          );
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
          
  "You are not the person assigned to this solve and cannot mark it disproven.",
  ),);
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
    return super.close();
  }

  Future<void> _onNewFactCreated(
    NewFactCreated event,
    Emitter<IssueState> emit,
  ) async {
    final issueId = _currentIssueId;

    if (issueId == null) {
      emit(const IssuesListFailure('No Issue Selected'));
      return;
    }

    // Get userId from AuthRepository
    final userId = _currentUserId;
    if (userId == null) {
      emit(const IssuesListFailure('User not authenticated'));
      return;
    }

    try {
      // Call the addFact method
      var factId = await issueRepository.addFact(
        issueId,
        event.referenceObjectType, // Pass the reference object type
        event.referenceObjectId, // Pass the reference object ID
        event.newFactContext, // Pass the fact context
        event.newFact, // Pass the fact description
        userId, // Pass the userId
      );

      if (factId != null &&
          event.referenceObjectType == ReferenceObjectType.hypothesis) {
        // Update the hypothesis with the new fact
        final currentHypothesis = await issueRepository.getHypothesisById(
            issueId, event.referenceObjectId);
        // Create a new map based on the current factIds
        if (currentHypothesis != null) {
          final updatedFactIds =
              Map<String, String>.from(currentHypothesis.factIds)
                ..[userId] = factId;
          final updatedHypothesis =
              currentHypothesis.copyWith(factIds: updatedFactIds);
          await issueRepository.updateHypothesis(issueId, updatedHypothesis);
        }
      }

      // No need to emit a new state; the UI will update via the stream
    } catch (error) {
      emit(IssuesListFailure(error.toString()));
    }
  }

  Future<void> _onAddUserToIssueEvent(
    AddUserToIssueEvent event,
    Emitter<IssueState> emit,
  ) async {
    try {
      // Fetch the issue
      final issue = await issueRepository.getIssueById(event.issueId);
      if (issue == null) {
        emit(IssuesListFailure('Issue not found.'));
        return;
      }

      // Add the user to the invitedUserIds
      issue.invitedUserIds?.add(event.userId);

      // Update the issue in the repository
      await issueRepository.updateIssue(issue.issueId!, issue);
    } catch (e) {
      emit(IssuesListFailure(e.toString()));
    }
  }
}
