part of 'issue_bloc.dart';

@immutable
sealed class IssueState {}

final class IssueInitial extends IssueState {}

final class IssuesListSuccess extends IssueState {
  final Stream<List<Issue>> issueList;

  IssuesListSuccess({required this.issueList});
}

final class IssuesListLoading extends IssueState {}

final class IssuesListFailure extends IssueState {
  final String error;

  IssuesListFailure(this.error);
}
