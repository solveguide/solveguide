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
}
