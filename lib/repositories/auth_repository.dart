import 'package:firebase_auth/firebase_auth.dart';
import 'package:guide_solve/repositories/appUser_repository.dart';

class AuthRepository {
  AuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  final AppUserRepository _appUserRepository = AppUserRepository();
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
    var cleanEmail = email.trim().toLowerCase();
    try {
      // Create User
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      // Create new user in Firestore 'users' collection
      final user = userCredential.user;
      if (user != null) {
        await _appUserRepository.createAppUser(user, cleanEmail);
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
    var cleanEmail = email.trim().toLowerCase();
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );
      if (userCredential.user != null) {
        final userId = userCredential.user!.uid;
        if (await _appUserRepository.appUserExistsById(userId)) {
          //update
          _appUserRepository.updateAppUserById(userCredential.user!.uid);
        } else {
          _appUserRepository.createAppUser(userCredential.user!, cleanEmail);
        }
      }

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
