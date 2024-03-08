class RootTheory {
  final String desc;
  bool isRoot;
  bool isSpinoffIssue;
  int rank;

  RootTheory({
    required this.desc,
    this.isRoot = false,
    this.isSpinoffIssue = false,
    required this.rank,
  });
}