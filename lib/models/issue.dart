import 'package:guide_solve/models/hypothesis.dart';
import 'package:guide_solve/models/solution.dart';

class Issue {
  Issue({
    required this.label,
    required this.seedStatement,
    required this.ownerId,
    required this.createdTimestamp,
    required this.lastUpdatedTimestamp,
    this.issueId,
    this.spinoffSourceIssueId,
    this.root = '',
    this.rootHypothesisId = '',
    this.solve = '',
    this.solveSolutionId = '',
    this.proven = false,
    List<String>? invitedUserIds,
  }) : invitedUserIds = invitedUserIds ?? [];

  // Create an Issue from a Map
  factory Issue.fromJson(Map<String, dynamic> json) => Issue(
        issueId: json['issueId'] as String?,
        spinoffSourceIssueId: json['spinoffSourceIssueId'] as String?,
        label: json['label'] as String,
        seedStatement: json['seedStatement'] as String,
        root: json['root'] as String? ?? 'No root selected.',
        rootHypothesisId: json['rootHypothesisId'] as String? ?? '',
        solve: json['solve'] as String? ?? 'No solve selected.',
        solveSolutionId: json['solveSolutionId'] as String? ?? '',
        proven: json['proven'] as bool? ?? false,
        ownerId: json['ownerId'] as String,
        invitedUserIds: (json['invitedUserIds'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        createdTimestamp: DateTime.parse(json['createdTimestamp'] as String),
        lastUpdatedTimestamp:
            DateTime.parse(json['lastUpdatedTimestamp'] as String),
      );

  String? issueId; // Firebase ID once the issue is saved
  String? spinoffSourceIssueId; // ID of the original issue if it's a spinoff
  String label;
  final String seedStatement; // The original thought input by the user
  String root;
  String rootHypothesisId;
  String solve;
  String solveSolutionId;
  bool proven;
  final String ownerId; // ID of the user who owns the issue
  List<String>? invitedUserIds; // List of user IDs with limited permissions
  final DateTime createdTimestamp;
  final DateTime lastUpdatedTimestamp;

  // Convert an Issue to a Map
  Map<String, dynamic> toJson() => {
        'issueId': issueId,
        'spinoffSourceIssueId': spinoffSourceIssueId,
        'label': label,
        'seedStatement': seedStatement,
        'root': root,
        'rootHypothesisId': rootHypothesisId,
        'solve': solve,
        'solveSolutionId': solveSolutionId,
        'proven': proven,
        'ownerId': ownerId,
        'invitedUserIds': invitedUserIds,
        'createdTimestamp': createdTimestamp.toIso8601String(),
        'lastUpdatedTimestamp': lastUpdatedTimestamp.toIso8601String(),
      };

// Provide a new copy of this issue with modified data.
  Issue copyWith({
    String? issueId,
    String? spinoffSourceIssueId,
    String? label,
    String? seedStatement,
    String? root,
    String? rootHypothesisId,
    String? solve,
    String? solveSolutionId,
    bool? proven,
    String? ownerId,
    List<String>? invitedUserIds,
    DateTime? createdTimestamp,
    DateTime? lastUpdatedTimestamp,
  }) {
    return Issue(
      issueId: issueId ?? this.issueId,
      spinoffSourceIssueId: spinoffSourceIssueId ?? this.spinoffSourceIssueId,
      label: label ?? this.label,
      seedStatement: seedStatement ?? this.seedStatement,
      root: root ?? this.root,
      rootHypothesisId: rootHypothesisId ?? this.rootHypothesisId,
      solve: solve ?? this.solve,
      solveSolutionId: solveSolutionId ?? this.solveSolutionId,
      proven: proven ?? this.proven,
      ownerId: ownerId ?? this.ownerId,
      invitedUserIds: invitedUserIds ?? this.invitedUserIds,
      createdTimestamp: createdTimestamp ?? this.createdTimestamp,
      lastUpdatedTimestamp: lastUpdatedTimestamp ?? this.lastUpdatedTimestamp,
    );
  }

  // Perspective for the issue
  IssuePerspective perspective(String currentUserId, List<Hypothesis> hypotheses, List<Solution> solutions) {
    return IssuePerspective(this, currentUserId, hypotheses, solutions);
  }
}

class IssuePerspective {
  IssuePerspective(this.issue, this.currentUserId, this.hypotheses, this.solutions);

  final Issue issue;
  final String currentUserId;
  final List<Hypothesis> hypotheses;
  final List<Solution> solutions;

  /// Check if the current user has voted on all hypotheses.
  bool hasCurrentUserVotedOnAllHypotheses() {
    return hypotheses
        .every((hypothesis) => hypothesis.votes.containsKey(currentUserId));
  }

  /// Check if all stakeholders have voted on all hypotheses.
  bool haveAllStakeholdersVotedOnAllHypotheses() {
    final invitedUserIds = issue.invitedUserIds;
    return hypotheses.every((hypothesis) {
      return invitedUserIds!
          .every((userId) => hypothesis.votes.containsKey(userId));
    });
  }

    /// Get the number of hypotheses
  int numberOfHypotheses() {
    return hypotheses.length;
  }

  /// Get the number of hypotheses where the current user is in conflict.
  int numberOfHypothesesInConflict() {
    return hypotheses.where((hypothesis) {
      final perspective =
          hypothesis.perspective(currentUserId, issue.invitedUserIds!);
      return perspective.isCurrentUserInConflict();
    }).length;
  }

  /// Check if the current user has voted "root" on any hypothesis.
  bool hasCurrentUserVotedRoot() {
    return hypotheses.any((hypothesis) =>
        hypothesis.votes[currentUserId] == HypothesisVote.root.name);
  }

  /// Check if the issue has a consensus root.
  bool hasConsensusRoot() {
    return hypotheses.any((hypothesis) {
      final invitedUserIds = issue.invitedUserIds;
      return invitedUserIds!.every(
          (userId) => hypothesis.votes[userId] == HypothesisVote.root.name);
    });
  }

  /// Check if the current user has voted on all solutions.
  bool hasCurrentUserVotedOnAllSolutions() {
    return solutions
        .every((solution) => solution.votes.containsKey(currentUserId));
  }

  /// Check if all stakeholders have voted on all solutions.
  bool haveAllStakeholdersVotedOnAllSolutions() {
    final invitedUserIds = issue.invitedUserIds;
    return solutions.every((solution) {
      return invitedUserIds!
          .every((userId) => solution.votes.containsKey(userId));
    });
  }

  /// Get the number of solutions
  int numberOfSolutions() {
    return solutions.length;
  }

  /// Get the number of solutions where the current user is in conflict.
  int numberOfSolutionsInConflict() {
    return solutions.where((solution) {
      final perspective =
          SolutionPerspective(solution, currentUserId, issue.invitedUserIds!);
      return perspective.isCurrentUserInConflict();
    }).length;
  }

  /// Check if the current user has voted "solve" on any solution.
  bool hasCurrentUserVotedSolve() {
    return solutions.any(
        (solution) => solution.votes[currentUserId] == SolutionVote.solve.name);
  }

  /// Check if the issue has a consensus solve.
  bool hasConsensusSolve() {
    return solutions.any((solution) {
      final invitedUserIds = issue.invitedUserIds;
      return invitedUserIds!
          .every((userId) => solution.votes[userId] == SolutionVote.solve.name);
    });
  }
}
