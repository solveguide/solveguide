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
  StreamSubscription<Issue>? _focusedIssueSubscription;
  Issue? _focusedIssue;
  String? _currentIssueId;
  String? _currentUserId;

  String? get currentUserId => _currentUserId;
  String? get currentIssueId => _currentIssueId;
  Issue? get focusedIssue => _focusedIssue;
  StreamSubscription<Issue>? get focusedIssueStream =>
      _focusedIssueSubscription;

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
    // Cancel any existing subscription
    await _focusedIssueSubscription?.cancel();

    _currentIssueId = event.issueId;

    // Start listening to the focused issue stream
    _focusedIssueSubscription =
        issueRepository.getFocusedIssueStream(event.issueId).listen(
      (issue) {
        // Store the latest issue from the stream
        _focusedIssue = issue;

        // Emit the FocusedIssueUpdated event only after _focusedIssue is set
        // ignore: prefer_const_constructors
        add(
          FocusedIssueUpdated(
            issue,
          ),
        ); // Removed 'const' here since we want the updated data
      },
      onError: (Object error, StackTrace stackTrace) {
        emit(IssuesListFailure(error.toString()));
      },
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

    // Get the appropriate streams for the current issue
    final hypothesesStream = issueRepository.getHypotheses(_currentIssueId!);
    final solutionsStream = issueRepository.getSolutions(_currentIssueId!);

    final hypotheses = await hypothesesStream.first;
    final solutions = await solutionsStream.first;

    final perspective =
        _focusedIssue!.perspective(_currentUserId!, hypotheses, solutions);

    emit(
      IssueProcessState(
        stage: stage,
        hypothesesStream: hypothesesStream,
        solutionsStream: solutionsStream,
        perspective: perspective,
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
      // Retrieve the current state and make sure it's an IssueProcessState
      if (state is! IssueProcessState) return;

      // Cast state to IssueProcessState
      final currentState = state as IssueProcessState;

      // Ensure _currentIssueId is available
      if (_currentIssueId == null) {
        throw Exception('_currentIssueId is not set');
      }

      // Fetch the current hypotheses for the issue
      final currentHypotheses =
          await issueRepository.getHypotheses(_currentIssueId!).first;

      // Find the hypothesis to be updated
      final hypothesis = currentHypotheses.firstWhere(
        (h) => h.hypothesisId == event.hypothesisId,
        orElse: () => throw Exception('Hypothesis not found'),
      );

      //get IssuePerspective
      final hypotheses = await currentState.hypothesesStream!.first;
      final solutions = await currentState.solutionsStream!.first;

      final perspective =
          _focusedIssue!.perspective(_currentUserId!, hypotheses, solutions);

      //Remove old root if user is voting on a new root
      if (event.voteValue == 'root' && perspective.hasCurrentUserVotedRoot()) {
        final unVoteRoot = Map<String, String>.from(hypothesis.votes)
          ..[_currentUserId!] = 'agree';
        final oldRoot = perspective
            .getUsersCurrentRootHypothesis()!
            .copyWith(votes: unVoteRoot);
        await issueRepository.updateHypothesis(
          _currentIssueId!,
          oldRoot,
        );
      }

      // Update the votes map with the current user's vote
      final updatedVotes = Map<String, String>.from(hypothesis.votes)
        ..[_currentUserId!] = event.voteValue;

      // Create a new hypothesis object with updated votes
      final updatedHypothesis = hypothesis.copyWith(votes: updatedVotes);

      // Update the hypothesis in Firestore using the repository
      await issueRepository.updateHypothesis(
        _currentIssueId!,
        updatedHypothesis,
      );

      if (event.voteValue == 'root') {
        add(FocusIssueNavigationRequested(stage: IssueProcessStage.narrowingToRootCause));
      } else {
        final stage = currentState.stage;
        add(FocusIssueNavigationRequested(stage: stage));
      }
    } catch (e) {
      // Handle errors and update the state accordingly
      emit(IssuesListFailure(e.toString()));
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
    _focusedIssueSubscription?.cancel();
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
    final userId = await authRepository.getUserUid();
    if (userId == null) {
      emit(const IssuesListFailure('User not authenticated'));
      return;
    }

    try {
      // Call the addFact method
      await issueRepository.addFact(
        issueId,
        event.referenceObjectType, // Pass the reference object type
        event.referenceObjectId, // Pass the reference object ID
        event.newFactContext, // Pass the fact context
        event.newFact, // Pass the fact description
        userId, // Pass the userId
      );

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
