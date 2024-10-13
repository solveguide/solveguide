import 'package:guide_solve/bloc/issue/issue_bloc.dart'; 

enum Vote {
  root,
  agree,
  disagree,
  spinoff,
}

class Hypothesis {
  // A map to store user votes (userId -> voteValue)

  Hypothesis({
    required this.ownerId,
    required this.desc,
    required this.createdTimestamp,
    required this.lastUpdatedTimestamp,
    this.hypothesisId,
    this.isRoot = false,
    this.isSpinoffIssue = false,
    this.spinoffIssueId,
    this.rank = 0,
    this.votes = const {}, // Initialize with an empty map
  });

  // Create a Hypothesis from a Map
  factory Hypothesis.fromJson(Map<String, dynamic> json) => Hypothesis(
        hypothesisId: json['hypothesisId'] as String?,
        ownerId: json['ownerId'] as String,
        desc: json['desc'] as String,
        isRoot: json['isRoot'] as bool? ?? false,
        isSpinoffIssue: json['isSpinoffIssue'] as bool? ?? false,
        spinoffIssueId: json['spinoffIssueId'] as String?,
        rank: json['rank'] as int? ?? 0,
        createdTimestamp: DateTime.parse(json['createdTimestamp'] as String),
        lastUpdatedTimestamp:
            DateTime.parse(json['lastUpdatedTimestamp'] as String),
        votes: Map<String, String>.from(
          json['votes'] as Map<String, dynamic>? ?? {},
        ),
      );

  String? hypothesisId;
  final String ownerId; // ID of the user who owns the hypothesis
  final String desc;
  bool isRoot;
  bool isSpinoffIssue;
  String? spinoffIssueId;
  int rank;
  final DateTime createdTimestamp;
  final DateTime lastUpdatedTimestamp;
  Map<String, String> votes; // Vote Map: userId -> vote

  // Convert a Hypothesis to a Map
  Map<String, dynamic> toJson() => {
        'hypothesisId': hypothesisId,
        'ownerId': ownerId,
        'desc': desc,
        'isRoot': isRoot,
        'isSpinoffIssue': isSpinoffIssue,
        'spinoffIssueId': spinoffIssueId,
        'rank': rank,
        'createdTimestamp': createdTimestamp.toIso8601String(),
        'lastUpdatedTimestamp': lastUpdatedTimestamp.toIso8601String(),
        'votes': votes, // Store the votes map
      };

  // Add the copyWith method
  Hypothesis copyWith({
    String? hypothesisId,
    String? ownerId,
    String? desc,
    bool? isRoot,
    bool? isSpinoffIssue,
    String? spinoffIssueId,
    int? rank,
    DateTime? createdTimestamp,
    DateTime? lastUpdatedTimestamp,
    Map<String, String>? votes,
  }) {
    return Hypothesis(
      hypothesisId: hypothesisId ?? this.hypothesisId,
      ownerId: ownerId ?? this.ownerId,
      desc: desc ?? this.desc,
      isRoot: isRoot ?? this.isRoot,
      isSpinoffIssue: isSpinoffIssue ?? this.isSpinoffIssue,
      spinoffIssueId: spinoffIssueId ?? this.spinoffIssueId,
      rank: rank ?? this.rank,
      createdTimestamp: createdTimestamp ?? this.createdTimestamp,
      lastUpdatedTimestamp: lastUpdatedTimestamp ?? this.lastUpdatedTimestamp,
      votes: votes ?? this.votes,
    );
  }

  // Perspective utility functions encapsulated within Hypothesis
  Perspective perspective(String currentUserId, List<String> invitedUserIds) {
    return Perspective(this, currentUserId, invitedUserIds);
  }
}

class Perspective {
  Perspective(
    this.hypothesis,
    this.currentUserId,
    this.invitedUserIds,
  );

  final Hypothesis hypothesis;
  final String currentUserId;
  final List<String> invitedUserIds;

  /// Get the current user's vote.
  Vote? getCurrentUserVote() {
    final voteString = hypothesis.votes[currentUserId];
    return voteString != null ? Vote.values.byName(voteString) : null;
  }

  /// Determine if all stakeholders have voted.
  bool allStakeholdersVoted() {
    final votes = hypothesis.votes.keys.toSet();
    final invitedSet = invitedUserIds.toSet();
    return invitedSet.difference(votes).isEmpty;
  }

  /// Calculate voter turnout percentage.
  double voterTurnoutPercentage() {
    if (invitedUserIds.isEmpty) return 0;
    final voteCount = hypothesis.votes.length;
    return (voteCount / invitedUserIds.length) * 100;
  }

  /// Check if the current user's vote is in conflict with any other user's vote
  bool isCurrentUserInConflict() {
    final currentUserVote = getCurrentUserVote();
    if (currentUserVote == null) return false;

    for (final entry in hypothesis.votes.entries) {
      if (entry.key == currentUserId) continue; // Skip current user's vote

      final otherUserVote = Vote.values.byName(entry.value);
      if (_isConflict(currentUserVote, otherUserVote)) {
        return true;
      }
    }
    return false;
  }

  /// Determine if two votes are in conflict.
  bool _isConflict(Vote vote1, Vote vote2) {
    if ((vote1 == Vote.root && vote2 == Vote.agree) ||
        (vote1 == Vote.agree && vote2 == Vote.root)) {
      return false;
    }
    if ((vote1 == Vote.disagree && vote2 == Vote.spinoff) ||
        (vote1 == Vote.spinoff && vote2 == Vote.disagree)) {
      return false;
    }
    return vote1 != vote2;
  }

  /// Calculate the rank of the hypothesis.
  int calculateRank(IssueProcessStage stage) {
    var rank = 0;
    final currentUserVote = getCurrentUserVote();

    // Assign rank based on consensus and user vote
    switch (stage) {
      case IssueProcessStage.wideningHypotheses:
        rank += _rankForWidening();

      case IssueProcessStage.narrowingToRootCause:
        rank += _rankForNarrowing(currentUserVote);

      case IssueProcessStage.wideningSolutions:
        break;
      case IssueProcessStage.narrowingToSolve:
        break;
      case IssueProcessStage.establishingFacts:
        break;
      case IssueProcessStage.scopingSolve:
        break;
      case IssueProcessStage.solveSummaryReview:
        break;
    }
    return rank;
  }

  int _rankForWidening() {
    final consensusVotes = hypothesis.votes.values;

    // Determine the number of stakeholders for assigning root vote value
    final numberOfStakeholders = invitedUserIds.length;

    // Assign points to each type of vote
    final rootPoints =
        consensusVotes.where((vote) => vote == Vote.root.name).length *
            numberOfStakeholders;
    final agreePoints =
        consensusVotes.where((vote) => vote == Vote.agree.name).length * 2;
    final disagreePoints =
        consensusVotes.where((vote) => vote == Vote.disagree.name).length * -1;
    final spinoffPoints =
        consensusVotes.where((vote) => vote == Vote.spinoff.name).length * -10;

    // Total points to determine the rank
    final totalPoints =
        rootPoints + agreePoints + disagreePoints + spinoffPoints;

    return totalPoints;
  }

  int _rankForNarrowing(Vote? currentUserVote) {
    final consensusVotes = hypothesis.votes.values;
    final rootCount =
        consensusVotes.where((vote) => vote == Vote.root.name).length;

    // Assign the primary rank value
    int primaryRank;

    if (rootCount == invitedUserIds.length) {
      primaryRank = 1000; // All users voted root, give the highest rank
    } else if (isCurrentUserInConflict()) {
      primaryRank = 500; // Current user is in conflict, second highest rank
    } else if (currentUserVote == null) {
      primaryRank = 200; // Current user has not voted yet, third highest rank
    } else {
      // General consensus as the lowest rank, reuse the rank from widening
      primaryRank = 0;
    }

    // Assign a secondary rank for sorting hypotheses with the same primary rank
    final consensusRank = _rankForWidening();

    // Combine the primary and secondary rank, using order of magnitude
    return primaryRank + consensusRank;
  }
}
