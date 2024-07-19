class Solution {
  final String desc;
  bool isSolve;
  int rank;

  Solution({
    required this.desc,
    this.isSolve = false,
    this.rank = 0,
  });

  // Convert a Solution to a Map
  Map<String, dynamic> toJson() => {
        'desc': desc,
        'isSolve': isSolve,
        'rank': rank,
      };

  // Create a Solution from a Map
  factory Solution.fromJson(Map<String, dynamic> json) => Solution(
        desc: json['desc'],
        isSolve: json['isSolve'] ?? false,
        rank: json['rank'] ?? 0,
      );
}
