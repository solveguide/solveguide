import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:guide_solve/models/appUser.dart';

class AuthRepository {
  AuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;
  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');
// validate email
  bool isValidEmail(String email) {
    final emailRegExp = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    );
    return emailRegExp.hasMatch(email);
  }

// send verification email
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw Exception('Failed to send verification email.');
    }
  }

// register
  Future<User?> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      // Create User
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create new user in Firestore 'users' collection
      final user = userCredential.user;
      if (user != null) {
        final privateAreaId = 'p${user.uid}';
        final privateArea = IssueArea(
            label: 'Private', userIds: [user.uid], issueAreaId: privateAreaId);

        await _userCollection.doc(user.uid).set(
          {
            'userId': user.uid,
            'email': email,
            'username': email,
            'createdTimestamp': DateTime.now(),
            'lastLoginTimestamp': DateTime.now(),
            'contacts': <String>[], // Explicitly typed as List<String>
            'issueAreas': [privateArea.toJson()], // Add initial private area
            'invitedContacts': <String>[], // Explicitly typed as List<String>
          },
        );
      }

      return user;
    } on FirebaseAuthException catch (e) {
      // Handle specific error codes if needed
      throw Exception(e.message);
    }
  }

// sign in
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Handle specific error codes if needed
      throw Exception(e.message);
    }
  }

// sign out

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

// lost password
// validate password

// check authentication status
  Future<User> getCurrentUser() async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null) {
        return currentUser;
      } else {
        throw Exception('The current user is null');
      }
    } catch (error) {
      throw Exception('Failed to get current user: $error');
    }
  }

  Future<String?> getUserUid() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('User is not logged in');
      }
      return user.uid;
    } catch (e) {
      throw Exception('Failed to get user UID: $e');
    }
  }
}
