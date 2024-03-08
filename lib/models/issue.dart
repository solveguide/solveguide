import 'package:guide_solve/models/root_theory.dart';

class Issue {
  final String label;
  final String root;
  final List<RootTheory> rootTheories;

  Issue({required this.label, required this.root, required this.rootTheories});
}