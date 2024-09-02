class ActionItem {
  final String description;
  bool isCompleted;

  ActionItem({
    required this.description,
    this.isCompleted = false,
  });

  // Convert an ActionItem to a Map
  Map<String, dynamic> toJson() => {
        'description': description,
        'isCompleted': isCompleted,
      };

  // Create an ActionItem from a Map
  factory ActionItem.fromJson(Map<String, dynamic> json) => ActionItem(
        description: json['description'],
        isCompleted: json['isCompleted'] ?? false,
      );

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
  final String desc;
  bool isSolve;
  int rank;
  List<String>? provenIssueIds;
  List<String>? disprovenIssueIds;
  String? assignedStakeholderUserId;
  List<ActionItem>? actionItems;
  DateTime? dueDate;

  Solution({
    required this.desc,
    this.isSolve = false,
    this.rank = 0,
    List<String>? provenIssueIds,
    List<String>? disprovenIssueIds,
    this.assignedStakeholderUserId,
    this.actionItems,
    this.dueDate,
  }) {
    provenIssueIds = provenIssueIds ?? [];
    disprovenIssueIds = disprovenIssueIds ?? [];
    actionItems = actionItems ?? [];
  }

  // Convert a Solution to a Map
  Map<String, dynamic> toJson() => {
        'desc': desc,
        'isSolve': isSolve,
        'rank': rank,
        'provenIssueIds': provenIssueIds,
        'disprovenIssueIds': disprovenIssueIds,
        'assignedStakeholderUserId': assignedStakeholderUserId,
        'actionItems': actionItems?.map((item) => item.toJson()).toList(),
        'dueDate': dueDate?.toIso8601String(),
      };

  // Create a Solution from a Map
  factory Solution.fromJson(Map<String, dynamic> json) => Solution(
        desc: json['desc'],
        isSolve: json['isSolve'] ?? false,
        rank: json['rank'] ?? 0,
        provenIssueIds: List<String>.from(json['invitedUserIds'] ?? []),
        disprovenIssueIds: List<String>.from(json['invitedUserIds'] ?? []),
        assignedStakeholderUserId: json['assignedStakeholderUserId'],
        actionItems: (json['actionItems'] as List<dynamic>?)
            ?.map((item) => ActionItem.fromJson(item))
            .toList(),
        dueDate:
            json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      );

  // CopyWith function
  Solution copyWith({
    String? desc,
    bool? isSolve,
    int? rank,
    List<String>? provenIssueIds,
    List<String>? disprovenIssueIds,
    String? assignedStakeholderUserId,
    List<ActionItem>? actionItems,
    DateTime? dueDate,
  }) {
    return Solution(
      desc: desc ?? this.desc,
      isSolve: isSolve ?? this.isSolve,
      rank: rank ?? this.rank,
      provenIssueIds: provenIssueIds ?? this.provenIssueIds,
      disprovenIssueIds: disprovenIssueIds ?? this.disprovenIssueIds,
      assignedStakeholderUserId:
          assignedStakeholderUserId ?? this.assignedStakeholderUserId,
      actionItems: actionItems ?? this.actionItems,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}
