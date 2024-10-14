class ActionItem {
  ActionItem({
    required this.description,
    this.isCompleted = false,
  });

  // Create an ActionItem from a Map
  factory ActionItem.fromJson(Map<String, dynamic> json) => ActionItem(
        description: json['description'] as String,
        isCompleted: json['isCompleted'] as bool,
      );

  final String description;
  bool isCompleted;

  // Convert an ActionItem to a Map
  Map<String, dynamic> toJson() => {
        'description': description,
        'isCompleted': isCompleted,
      };

  ActionItem copyWith({
    String? description,
    bool? isCompleted,
  }) {
    return ActionItem(
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

enum SolutionVote {
  solve,
  agree,
  disagree,
}

class Solution {
  // A map to store user votes (userId -> voteValue)

  Solution({
    required this.ownerId,
    required this.desc,
    required this.createdTimestamp,
    required this.lastUpdatedTimestamp,
    this.solutionId,
    this.isSolve = false,
    this.rank = 0,
    List<String>? provenIssueIds,
    List<String>? disprovenIssueIds,
    this.assignedStakeholderUserId,
    this.actionItems,
    this.dueDate,
    this.votes = const {}, // Initialize with an empty map
  }) {
    provenIssueIds = provenIssueIds ?? [];
    disprovenIssueIds = disprovenIssueIds ?? [];
    actionItems = actionItems ?? [];
  }

  // Create a Solution from a Map
  factory Solution.fromJson(Map<String, dynamic> json) => Solution(
        solutionId: json['solutionId'] as String?,
        ownerId: json['ownerId'] as String,
        desc: json['desc'] as String,
        isSolve: json['isSolve'] as bool? ?? false,
        rank: json['rank'] as int? ?? 0,
        provenIssueIds: (json['provenIssueIds'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        disprovenIssueIds: (json['disprovenIssueIds'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        assignedStakeholderUserId: json['assignedStakeholderUserId'] as String?,
        actionItems: (json['actionItems'] as List<dynamic>?)
            ?.map((item) => ActionItem.fromJson(item as Map<String, dynamic>))
            .toList(),
        dueDate: json['dueDate'] != null
            ? DateTime.parse(json['dueDate'] as String)
            : null,
        createdTimestamp: DateTime.parse(json['createdTimestamp'] as String),
        lastUpdatedTimestamp:
            DateTime.parse(json['lastUpdatedTimestamp'] as String),
        votes: Map<String, String>.from(
          json['votes'] as Map<String, dynamic>? ?? {},
        ),
      );

  String? solutionId;
  final String ownerId; // ID of the user who owns the solution
  final String desc;
  bool isSolve;
  int rank;
  List<String>? provenIssueIds;
  List<String>? disprovenIssueIds;
  String? assignedStakeholderUserId;
  List<ActionItem>? actionItems;
  DateTime? dueDate;
  final DateTime createdTimestamp;
  final DateTime lastUpdatedTimestamp;
  Map<String, String> votes;

  // Convert a Solution to a Map
  Map<String, dynamic> toJson() => {
        'solutionId': solutionId,
        'ownerId': ownerId,
        'desc': desc,
        'isSolve': isSolve,
        'rank': rank,
        'provenIssueIds': provenIssueIds,
        'disprovenIssueIds': disprovenIssueIds,
        'assignedStakeholderUserId': assignedStakeholderUserId,
        'actionItems': actionItems?.map((item) => item.toJson()).toList(),
        'dueDate': dueDate?.toIso8601String(),
        'createdTimestamp': createdTimestamp.toIso8601String(),
        'lastUpdatedTimestamp': lastUpdatedTimestamp.toIso8601String(),
        'votes': votes, // Store the votes map
      };

  // CopyWith function
  Solution copyWith({
    String? solutionId,
    String? ownerId,
    String? desc,
    bool? isSolve,
    int? rank,
    List<String>? provenIssueIds,
    List<String>? disprovenIssueIds,
    String? assignedStakeholderUserId,
    List<ActionItem>? actionItems,
    DateTime? dueDate,
    DateTime? createdTimestamp,
    DateTime? lastUpdatedTimestamp,
    Map<String, String>? votes,
  }) {
    return Solution(
      solutionId: solutionId ?? this.solutionId,
      ownerId: ownerId ?? this.ownerId,
      desc: desc ?? this.desc,
      isSolve: isSolve ?? this.isSolve,
      rank: rank ?? this.rank,
      provenIssueIds: provenIssueIds ?? this.provenIssueIds,
      disprovenIssueIds: disprovenIssueIds ?? this.disprovenIssueIds,
      assignedStakeholderUserId:
          assignedStakeholderUserId ?? this.assignedStakeholderUserId,
      actionItems: actionItems ?? this.actionItems,
      dueDate: dueDate ?? this.dueDate,
      createdTimestamp: createdTimestamp ?? this.createdTimestamp,
      lastUpdatedTimestamp: lastUpdatedTimestamp ?? this.lastUpdatedTimestamp,
      votes: votes ?? this.votes,
    );
  }

    // Perspective utility functions encapsulated within Hypothesis
  SolutionPerspective perspective(String currentUserId, List<String> invitedUserIds) {
    return SolutionPerspective(this, currentUserId, invitedUserIds);
  }
}

class SolutionPerspective {
  SolutionPerspective(this.solution, this.currentUserId, this.invitedUserIds);

  final Solution solution;
  final String currentUserId;
  final List<String> invitedUserIds;

  /// Get the current user's vote.
  SolutionVote? getCurrentUserVote() {
    final voteString = solution.votes[currentUserId];
    return voteString != null ? SolutionVote.values.byName(voteString) : null;
  }

  /// Determine if all stakeholders have voted.
  bool allStakeholdersVoted() {
    final votes = solution.votes.keys.toSet();
    final invitedSet = invitedUserIds.toSet();
    return invitedSet.difference(votes).isEmpty;
  }

  /// Determine if all other stakeholders voted agree or solve.
  bool allOtherStakeholdersAgreeOrSolve() {
    for (final entry in solution.votes.entries) {
      if (entry.key == currentUserId) continue;
      final vote = SolutionVote.values.byName(entry.value);
      if (vote != SolutionVote.agree && vote != SolutionVote.solve) {
        return false;
      }
    }
    return true;
  }

  /// Calculate voter turnout percentage.
  double voterTurnoutPercentage() {
    if (invitedUserIds.isEmpty) return 0;
    final voteCount = solution.votes.length;
    return (voteCount / invitedUserIds.length) * 100;
  }

  /// Check if the current user's vote is in conflict with any other user's vote.
  bool isCurrentUserInConflict() {
    final currentUserVote = solution.votes[currentUserId];
    if (currentUserVote == null) return false;

    for (final entry in solution.votes.entries) {
      if (entry.key == currentUserId) continue;

      final otherUserVote = SolutionVote.values.byName(entry.value);
      final vote = SolutionVote.values.byName(currentUserVote);
      if (_isConflict(vote, otherUserVote)) {
        return true;
      }
    }
    return false;
  }

  /// Determine if two votes are in conflict.
  bool _isConflict(SolutionVote vote1, SolutionVote vote2) {
    if ((vote1 == SolutionVote.solve && vote2 == SolutionVote.agree) ||
        (vote1 == SolutionVote.agree && vote2 == SolutionVote.solve)) {
      return false;
    }
    return vote1 != vote2;
  }

  /// Calculate the rank of the solution based on consensus.
  int calculateConsensusRank() {
    final consensusVotes = solution.votes.values;

    // Determine the number of stakeholders for assigning solve vote value
    final numberOfStakeholders = invitedUserIds.length;

    // Assign points to each type of vote
    final solvePoints = consensusVotes
            .where((vote) => vote == SolutionVote.solve.name)
            .length *
        numberOfStakeholders;
    final agreePoints =
        consensusVotes.where((vote) => vote == SolutionVote.agree.name).length *
            2;
    final disagreePoints =
        consensusVotes.where((vote) => vote == SolutionVote.disagree.name).length *
            -1;

    // Total points to determine the rank
    final totalPoints = solvePoints + agreePoints + disagreePoints;

    return totalPoints;
  }

  /// Calculate the rank of the solution during the narrowing stage.
  int calculateNarrowingRank() {
    final currentUserVote = getCurrentUserVote();
    final consensusVotes = solution.votes.values;
    final solveCount =
        consensusVotes.where((vote) => vote == SolutionVote.solve.name).length;

    // Assign the primary rank value
    int primaryRank;

    if (solveCount == invitedUserIds.length) {
      primaryRank = 1000; // All users voted solve, give the highest rank
    } else if (isCurrentUserInConflict()) {
      primaryRank = 500; // Current user is in conflict, second highest rank
    } else if (currentUserVote == null) {
      primaryRank = 200; // Current user has not voted yet, third highest rank
    } else {
      primaryRank = 0; // General consensus as the lowest rank
    }

    // Assign a secondary rank for sorting solutions with the same primary rank
    final consensusRank = calculateConsensusRank();

    // Combine the primary and secondary rank, using order of magnitude
    return primaryRank + consensusRank;
  }
}