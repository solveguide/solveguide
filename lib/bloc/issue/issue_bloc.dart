import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guide_solve/models/issue.dart';
import 'package:guide_solve/repositories/issue_repository.dart';

part 'issue_event.dart';
part 'issue_state.dart';

class IssueBloc extends Bloc<IssueEvent, IssueState> {
  final IssueRepository issueRepository;
  IssueBloc(this.issueRepository) : super(IssueInitial()) {
    on<IssuesFetched>(_fetchIssues);
  }

void _fetchIssues(
  IssuesFetched event,
  Emitter<IssueState> emit,
) async {
  emit(IssuesListLoading());
  try {
    await emit.forEach<List<Issue>>(
      issueRepository.getIssuesStream(),
      onData: (issuesList) {
        if (issuesList.isEmpty) {
          return IssuesListFailure("Congratulations, you have no issues.");  // Custom state for empty list
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

}
