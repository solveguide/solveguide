import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'issue_event.dart';
part 'issue_state.dart';

class IssueBloc extends Bloc<IssueEvent, IssueState> {
  IssueBloc() : super(IssueInitial()) {
    on<IssueEvent>((event, emit) {
      // TOD: implement event handler
    });
  }
}
