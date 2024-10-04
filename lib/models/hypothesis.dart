class Hypothesis {
  String? hypothesisId;
  final String ownerId; // ID of the user who owns the hypothesis
  final String desc;
  bool isRoot;
  bool isSpinoffIssue;
  String? spinoffIssueId;
  int rank;
  final DateTime createdTimestamp;
  final DateTime lastUpdatedTimestamp;
  Map<String, String> votes; // A map to store user votes (userId -> voteValue)

  Hypothesis({
    this.hypothesisId,
    required this.ownerId,
    required this.desc,
    this.isRoot = false,
    this.isSpinoffIssue = false,
    String? spinoffIssueId,
    this.rank = 0,
    required this.createdTimestamp,
    required this.lastUpdatedTimestamp,
    this.votes = const {}, // Initialize with an empty map
  });

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

  // Create a Hypothesis from a Map
  factory Hypothesis.fromJson(Map<String, dynamic> json) => Hypothesis(
        hypothesisId: json['hypothesisId'],
        ownerId: json['ownerId'],
        desc: json['desc'],
        isRoot: json['isRoot'] ?? false,
        isSpinoffIssue: json['isSpinoffIssue'] ?? false,
        spinoffIssueId: json['spinoffIssueId'],
        rank: json['rank'] ?? 0,
        createdTimestamp: DateTime.parse(json['createdTimestamp']),
        lastUpdatedTimestamp: DateTime.parse(json['lastUpdatedTimestamp']),
        votes: Map<String, String>.from(json['votes'] ?? {}),
      );

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
}
