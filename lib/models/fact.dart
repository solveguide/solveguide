class Fact {
  // A map to store user votes (userId -> voteValue)

  Fact({
    required this.authorId,
    required this.desc,
    required this.createdTimestamp,
    required this.lastUpdatedTimestamp,
    this.factId,
    this.referenceObjects = const {}, // Default empty map
    this.parentIssueId,
    this.supportingContext,
    this.votes = const {}, // Initialize with an empty map
  });

// Create a Fact object from JSON (from Firestore or other storage)
  factory Fact.fromJson(Map<String, dynamic> json) => Fact(
        factId: json['factId'] as String?,
        authorId: json['authorId'] as String,
        desc: json['desc'] as String,
        createdTimestamp: DateTime.parse(json['createdTimestamp'] as String),
        lastUpdatedTimestamp:
            DateTime.parse(json['updatedTimestamp'] as String),
        referenceObjects:
            (json['referenceObjects'] as Map<String, dynamic>?)?.map(
                  (key, value) =>
                      MapEntry(key, List<String>.from(value as List<dynamic>)),
                ) ??
                {},
        parentIssueId: json['parentIssueId'] as String?,
        supportingContext: json['supportingContext'] as String?,
        votes: Map<String, String>.from(
          json['votes'] as Map<String, dynamic>? ?? {},
        ),
      );

  final String? factId; // Unique ID for the fact
  final String authorId; // ID of the user who authored the fact
  final String desc; // The actual fact description
  final DateTime createdTimestamp; // Timestamp when the fact was created
  final DateTime lastUpdatedTimestamp; // Timestamp for the last update
  final Map<String, List<String>>
      referenceObjects; // Map of reference types to their IDs
  final String? parentIssueId; // ID of the parent issue, optional
  final String? supportingContext; // Additional context for the fact
  Map<String, String> votes;

  // Convert a Fact object to JSON (for Firestore or other storage)
  Map<String, dynamic> toJson() => {
        'factId': factId,
        'authorId': authorId,
        'desc': desc,
        'createdTimestamp': createdTimestamp.toIso8601String(),
        'updatedTimestamp': lastUpdatedTimestamp.toIso8601String(),
        'referenceObjects': referenceObjects,
        'parentIssueId': parentIssueId,
        'supportingContext': supportingContext,
        'votes': votes, // Store the votes map
      };

  // Update the votes map (e.g., add or reverse a user's vote)
  void updateVote(String userId, String voteValue) {
    votes[userId] = voteValue;
  }

  // Remove a user's vote
  void removeVote(String userId) {
    votes.remove(userId);
  }

  // Add the copyWith method for immutability and updates
  Fact copyWith({
    String? factId,
    String? authorId,
    String? desc,
    DateTime? createdTimestamp,
    DateTime? lastUpdatedTimestamp,
    Map<String, List<String>>? referenceObjects,
    String? parentIssueId,
    String? supportingContext,
    Map<String, String>? votes,
  }) {
    return Fact(
      factId: factId ?? this.factId,
      authorId: authorId ?? this.authorId,
      desc: desc ?? this.desc,
      createdTimestamp: createdTimestamp ?? this.createdTimestamp,
      lastUpdatedTimestamp: lastUpdatedTimestamp ?? this.lastUpdatedTimestamp,
      referenceObjects: referenceObjects ?? this.referenceObjects,
      parentIssueId: parentIssueId ?? this.parentIssueId,
      supportingContext: supportingContext ?? this.supportingContext,
      votes: votes ?? this.votes,
    );
  }
}
