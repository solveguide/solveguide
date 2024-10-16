import 'package:guide_solve/bloc/issue/issue_bloc.dart';

enum HypothesisVote {
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
  HypothesisPerspective perspective(
      String currentUserId, List<String> invitedUserIds) {
    return HypothesisPerspective(this, currentUserId, invitedUserIds);
  }
}

class HypothesisPerspective {
  HypothesisPerspective(
    this.hypothesis,
    this.currentUserId,
    this.invitedUserIds,
  );

  final Hypothesis hypothesis;
  final String currentUserId;
  final List<String> invitedUserIds;

  /// Get the current user's vote.
  HypothesisVote? getCurrentUserVote() {
    final voteString = hypothesis.votes[currentUserId];
    return voteString != null ? HypothesisVote.values.byName(voteString) : null;
  }

  /// Determine if all stakeholders have voted.
  bool allStakeholdersVoted() {
    final votes = hypothesis.votes.keys.toSet();
    final invitedSet = invitedUserIds.toSet();
    return invitedSet.difference(votes).isEmpty;
  }

  /// Determine if all other stakeholders have voted 'agree' or 'root'.
  bool allOtherStakeholdersAgree() {
    // If there are no other stakeholders, return true.
    if (invitedUserIds.length <= 1) {
      if (getCurrentUserVote() == HypothesisVote.agree ||
          getCurrentUserVote() == HypothesisVote.root) {
        return true;
      }
      return false;
    }
    // Check if all stakeholders have voted
    if (!allStakeholdersVoted()) {
      return false;
    }

    for (final entry in hypothesis.votes.entries) {
      // Skip the current user's vote
      if (entry.key == currentUserId) {
        continue;
      }

      // Check if the vote is neither 'agree' nor 'root'
      final vote = HypothesisVote.values.byName(entry.value);
      if (vote != HypothesisVote.agree && vote != HypothesisVote.root) {
        return false;
      }
    }

    return true;
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

      final otherUserVote = HypothesisVote.values.byName(entry.value);
      if (_isConflict(currentUserVote, otherUserVote)) {
        return true;
      }
    }
    return false;
  }

  /// Determine if two votes are in conflict.
  bool _isConflict(HypothesisVote vote1, HypothesisVote vote2) {
    if ((vote1 == HypothesisVote.root && vote2 == HypothesisVote.agree) ||
        (vote1 == HypothesisVote.agree && vote2 == HypothesisVote.root)) {
      return false;
    }
    if ((vote1 == HypothesisVote.disagree && vote2 == HypothesisVote.spinoff) ||
        (vote1 == HypothesisVote.spinoff && vote2 == HypothesisVote.disagree)) {
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
    final rootPoints = consensusVotes
            .where((vote) => vote == HypothesisVote.root.name)
            .length *
        numberOfStakeholders;
    final agreePoints = consensusVotes
            .where((vote) => vote == HypothesisVote.agree.name)
            .length *
        2;
    final disagreePoints = consensusVotes
            .where((vote) => vote == HypothesisVote.disagree.name)
            .length *
        -1;
    final spinoffPoints = consensusVotes
            .where((vote) => vote == HypothesisVote.spinoff.name)
            .length *
        -10;

    // Total points to determine the rank
    final totalPoints =
        rootPoints + agreePoints + disagreePoints + spinoffPoints;

    return totalPoints;
  }

  int _rankForNarrowing(HypothesisVote? currentUserVote) {
    final consensusVotes = hypothesis.votes.values;
    final rootCount =
        consensusVotes.where((vote) => vote == HypothesisVote.root.name).length;

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
