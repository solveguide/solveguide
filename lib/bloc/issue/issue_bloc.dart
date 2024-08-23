import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/models/hypothesis.dart';
import 'package:guide_solve/models/issue.dart';
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
    Issue? focusIssue = issueRepository.getFocusIssue();

    if (focusIssue == null) {
      emit(IssuesListFailure("No Issue Selected"));
    } else {
      focusIssue.hypotheses.insert(
        0,
        Hypothesis(desc: event.newHypothesis),
      );
      emit(IssueInFocusInitial(focusedIssue: focusIssue));
    }
  }
}
