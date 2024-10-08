import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guide_solve/models/fact.dart';
import 'package:guide_solve/models/hypothesis.dart';
import 'package:guide_solve/models/issue.dart';
import 'package:guide_solve/models/solution.dart';

enum ReferenceObjectType {
  issue,
  hypothesis,
  solution,
  fact,
}

class IssueRepository {
  // Get collection of issues
  final CollectionReference _issuesCollection =
      FirebaseFirestore.instance.collection('issues');

// Get stream of issues where currentUserId is listed in the invitedUserIds map
Stream<List<Issue>> getIssuesStream(String currentUserId) {
  return _issuesCollection
      .where('invitedUserIds', arrayContains: currentUserId) 
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          return Issue.fromJson(doc.data() as Map<String, dynamic>);
        }).toList();
      }).handleError((error) {
        throw error.toString();
      });
}


//Get snapshot of list of issues owned by current user// Get snapshot of list of issues where currentUserId is listed in the invitedUserIds map
Future<List<Issue>> getIssueList(String currentUserId) async {
  try {
    // Fetch the snapshot from Firestore
    final snapshot = await _issuesCollection
        .where('invitedUserIds', arrayContains: currentUserId) // Querying the list, not the map
        .get();

    // Convert the snapshot into a List of Issue objects
    List<Issue> issuesList = snapshot.docs.map((doc) {
      return Issue.fromJson(doc.data() as Map<String, dynamic>);
    }).toList();

    // Sort the list by the lastUpdatedTimestamp field
    issuesList.sort(
        (a, b) => b.lastUpdatedTimestamp.compareTo(a.lastUpdatedTimestamp));

    return issuesList;
  } catch (error) {
    // Handle any errors that occur
    throw error.toString();
  }
}



  // Stream of the focused issue
  Stream<Issue> getFocusedIssueStream(String issueId) {
    return _issuesCollection.doc(issueId).snapshots().map((snapshot) {
      return Issue.fromJson(snapshot.data() as Map<String, dynamic>);
    });
  }

  //Fetch a Specific Issue by ID
  Future<Issue?> getIssueById(String issueId) async {
    try {
      DocumentSnapshot doc = await _issuesCollection.doc(issueId).get();

      if (doc.exists) {
        return Issue.fromJson(doc.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (error) {
      throw Exception('Failed to fetch Issue: $error');
    }
  }

// Create an issue
Future<void> addIssue(String seedStatement, String ownerId) async {
  final newIssue = Issue(
    label: seedStatement,
    seedStatement: seedStatement,
    ownerId: ownerId, // Use ownerId from AuthState
    createdTimestamp: DateTime.now(),
    lastUpdatedTimestamp: DateTime.now(),
    invitedUserIds: [ownerId],
  );
  try {
    // Add the issue to the Firestore collection
    final docRef = await _issuesCollection.add(newIssue.toJson());

    // Update the issue with the generated Firestore document ID
    await docRef.update({'issueId': docRef.id});
  } catch (error) {
    throw error.toString();
  }
}


  // Spinoff an issue
  Future<String> addSpinoffIssue(
      Issue oldIssue, String spinoffHypothesis, String ownerId) async {
    final newIssue = Issue(
      label: spinoffHypothesis,
      seedStatement: oldIssue.seedStatement,
      spinoffSourceIssueId: oldIssue.issueId,
      ownerId: ownerId, // Use ownerId from AuthState
      createdTimestamp: oldIssue.createdTimestamp,
      lastUpdatedTimestamp: DateTime.now(),
      root: oldIssue.root,
      solve: oldIssue.solve,
      invitedUserIds: oldIssue.invitedUserIds,
    );
    try {
      final docRef = await _issuesCollection.add(newIssue.toJson());
      await docRef.update({'issueId': docRef.id});
      return docRef.id;
    } catch (error) {
      throw error.toString();
    }
  }

  // Update an issue
  Future<void> updateIssue(String issueId, Issue issue) async {
    Issue updatedIssue = issue.copyWith(
      root: issue.root,
      solve: issue.solve,
      invitedUserIds: issue.invitedUserIds,
      lastUpdatedTimestamp: DateTime.now(),
    );
    try {
      await _issuesCollection.doc(issueId).update(updatedIssue.toJson());
    } catch (error) {
      throw error.toString();
    }
  }

  Future<void> updateIssueRoot(String issueId, String rootHypothesisId) async {
    try {
      Issue? currentIssue = await getIssueById(issueId);
      if (currentIssue == null) {
        throw "Issue is null";
      }
      Hypothesis? rootHypothesis =
          await getHypothesisById(issueId, rootHypothesisId);
      String updatedRoot = rootHypothesis!.desc;
      Issue updatedIssue = currentIssue.copyWith(
          root: updatedRoot, rootHypothesisId: rootHypothesisId);
      updateIssue(issueId, updatedIssue);
    } catch (error) {
      throw error.toString();
    }
  }

  Future<void> updateIssueSolve(String issueId, String solveSolutionId) async {
    try {
      Issue? currentIssue = await getIssueById(issueId);
      if (currentIssue == null) {
        throw "Issue is null";
      }
      Solution? solveSolution = await getSolutionById(issueId, solveSolutionId);
      String updatedSolve = solveSolution!.desc;
      Issue updatedIssue = currentIssue.copyWith(
          root: updatedSolve, solveSolutionId: solveSolutionId);
      updateIssue(issueId, updatedIssue);
    } catch (error) {
      throw error.toString();
    }
  }

  // Delete an issue
  Future<void> deleteIssue(String issueId) async {
    try {
      await _issuesCollection.doc(issueId).delete();
    } catch (error) {
      throw error.toString();
    }
  }

  // Fetch all hypotheses for a specific issue
  Stream<List<Hypothesis>> getHypotheses(String issueId) {
    return _issuesCollection
        .doc(issueId)
        .collection('hypotheses')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Hypothesis.fromJson(doc.data()))
            .toList());
  }

  // Fetch all solutions for a specific issue
  Stream<List<Solution>> getSolutions(String issueId) {
    return _issuesCollection
        .doc(issueId)
        .collection('solutions')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Solution.fromJson(doc.data())).toList());
  }

  // Fetch all facts for a specific issue
  Stream<List<Fact>> getFacts(String issueId) {
    return _issuesCollection.doc(issueId).collection('facts').snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => Fact.fromJson(doc.data())).toList());
  }

/*
SUBCOLLECTION FUNCTIONS
*/
//Add a new Hypothesis to an Issue
  Future<void> addHypothesis(
      String issueId, String hypothesisDesc, String ownerId) async {
    final newHypothesis = Hypothesis(
      ownerId: ownerId, // Use ownerId from AuthState
      desc: hypothesisDesc,
      createdTimestamp: DateTime.now(),
      lastUpdatedTimestamp: DateTime.now(),
    );
    try {
      // Reference to the hypotheses subcollection
      CollectionReference hypothesesRef =
          _issuesCollection.doc(issueId).collection('hypotheses');

      // Add the hypothesis document
      DocumentReference docRef =
          await hypothesesRef.add(newHypothesis.toJson());

      // Update the hypothesisId field with the generated document ID
      await docRef.update({'hypothesisId': docRef.id});
    } catch (error) {
      throw Exception('Failed to add hypothesis: $error');
    }
  }

//Add a new Solution to an Issue
  Future<void> addSolution(
      String issueId, String solutionDesc, String ownerId) async {
    final newSolution = Solution(
      ownerId: ownerId, // Use ownerId from AuthState
      desc: solutionDesc,
      createdTimestamp: DateTime.now(),
      lastUpdatedTimestamp: DateTime.now(),
    );
    try {
      // Reference to the solutions subcollection
      CollectionReference solutionsRef =
          _issuesCollection.doc(issueId).collection('solutions');

      // Add the solution document
      DocumentReference docRef = await solutionsRef.add(newSolution.toJson());

      // Update the solutionId field with the generated document ID
      await docRef.update({'solutionId': docRef.id});
    } catch (error) {
      throw Exception('Failed to add solution: $error');
    }
  }

//Add a new Fact to an Issue
  Future<void> addFact(
      String issueId,
      ReferenceObjectType refObjectType,
      String refObjectId,
      String factContext,
      String factDesc,
      String authorId) async {
    final newFact = Fact(
      authorId: authorId, // Use ownerId from AuthState
      desc: factDesc,
      referenceObjects: {
        refObjectType.toString(): [refObjectId]
      },
      supportingContext: factContext,
      createdTimestamp: DateTime.now(),
      lastUpdatedTimestamp: DateTime.now(),
    );
    try {
      // Reference to the solutions subcollection
      CollectionReference factRef =
          _issuesCollection.doc(issueId).collection('facts');

      // Add the fact document
      DocumentReference docRef = await factRef.add(newFact.toJson());

      // Update the factId field with the generated document ID
      await docRef.update({'factId': docRef.id});
    } catch (error) {
      throw Exception('Failed to add solution: $error');
    }
  }

//Fetch a Specific Hypothesis by ID
  Future<Hypothesis?> getHypothesisById(
      String issueId, String hypothesisId) async {
    try {
      DocumentSnapshot doc = await _issuesCollection
          .doc(issueId)
          .collection('hypotheses')
          .doc(hypothesisId)
          .get();

      if (doc.exists) {
        return Hypothesis.fromJson(doc.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (error) {
      throw Exception('Failed to fetch hypothesis: $error');
    }
  }

//Fetch a Specific Solution by ID
  Future<Solution?> getSolutionById(String issueId, String solutionId) async {
    try {
      DocumentSnapshot doc = await _issuesCollection
          .doc(issueId)
          .collection('solutions')
          .doc(solutionId)
          .get();

      if (doc.exists) {
        return Solution.fromJson(doc.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (error) {
      throw Exception('Failed to fetch solution: $error');
    }
  }

//Update an Existing Hypothesis
  Future<void> updateHypothesis(String issueId, Hypothesis hypothesis) async {
    Hypothesis updatedHypothesis = hypothesis.copyWith(
      lastUpdatedTimestamp: DateTime.now(),
    );
    try {
      await _issuesCollection
          .doc(issueId)
          .collection('hypotheses')
          .doc(hypothesis.hypothesisId)
          .update(updatedHypothesis.toJson());
    } catch (error) {
      throw Exception('Failed to update hypothesis: $error');
    }
  }

//Update an Existing Solution
  Future<void> updateSolution(String issueId, Solution solution) async {
    Solution updatedSolution = solution.copyWith(
      lastUpdatedTimestamp: DateTime.now(),
    );
    try {
      await _issuesCollection
          .doc(issueId)
          .collection('solutions')
          .doc(solution.solutionId)
          .update(updatedSolution.toJson());
    } catch (error) {
      throw Exception('Failed to update solution: $error');
    }
  }

//Delete a Hypothesis from an Issue
  Future<void> deleteHypothesis(String issueId, String hypothesisId) async {
    try {
      await _issuesCollection
          .doc(issueId)
          .collection('hypotheses')
          .doc(hypothesisId)
          .delete();
    } catch (error) {
      throw Exception('Failed to delete hypothesis: $error');
    }
  }

//Delete a Solution from an Issue
  Future<void> deleteSolution(String issueId, String solutionId) async {
    try {
      await _issuesCollection
          .doc(issueId)
          .collection('solutions')
          .doc(solutionId)
          .delete();
    } catch (error) {
      throw Exception('Failed to delete solution: $error');
    }
  }
}
