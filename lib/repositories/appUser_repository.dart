import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:guide_solve/models/appUser.dart';

class AppUserRepository {
  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');

  /// AppUser Methods
  /// 1. Create AppUser
  Future<void> createAppUser(User user, String email) async {
    final privateAreaId = 'p${user.uid}';
    final privateArea = IssueArea(
        label: 'Private', userIds: [user.uid], issueAreaId: privateAreaId);

    try {
      await _userCollection.doc(user.uid).set(
        {
          'userId': user.uid,
          'email': email.toLowerCase(),
          'username': email,
          'createdTimestamp': DateTime.now(),
          'lastLoginTimestamp': DateTime.now(),
          'contacts': {user.uid: "You"}, // Initialized in include self
          'issueAreas': [privateArea.toJson()], // Add initial private area
          'invitedContacts': <String>[], // Explicitly typed as List<String>
        },
      );
    } on Exception catch (e) {
      throw Exception('Failed to add AppUser: $e');
    }
  }

  /// Update AppUser
  Future<void> updateAppUser(AppUser user) async {
    // Add this method
    try {
      // Add this method
      await _userCollection.doc(user.userId).update(
        {
          'username': user.username,
          'lastLoginTimestamp': DateTime.now(),
          'contacts': user.contacts,
          'issueAreas': user.issueAreas,
          'invitedContacts': user.invitedContacts,
        },
      );
    } catch (e) {
      throw Exception('Failed to update AppUser: $e');
    }
  }

  /// Update AppUser by ID
  Future<void> updateAppUserById(String userId) async {
    // Add this method
    try {
      // Add this method
      await _userCollection.doc(userId).update(
        {
          'lastLoginTimestamp': DateTime.now(),
        },
      );
    } catch (e) {
      throw Exception('Failed to update AppUser: $e');
    }
  }

  /// 2. AppUserExists
  Future<bool> appUserExistsByEmail(String email) async {
    var cleanEmail = email.toLowerCase();
    // Add this method
    try {
      final querySnapshot =
          await _userCollection.where('email', isEqualTo: cleanEmail).limit(1).get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check if user exists: $e');
    }
  }

  Future<bool> appUserExistsById(String userId) async {
    // Add this method
    try {
      final querySnapshot = await _userCollection
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check if user exists: $e');
    }
  }

  /// 3. Get AppUser by Email
  Future<AppUser?> getAppUserByEmail(String email) async {
    var cleanEmail = email.toLowerCase();
    // Add this method
    try {
      final querySnapshot =
          await _userCollection.where('email', isEqualTo: cleanEmail).limit(1).get();
      if (querySnapshot.docs.isNotEmpty) {
        final docSnapshot = querySnapshot.docs.first;
        final data = docSnapshot.data();
        return AppUser.fromJson(data as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Failed to get user by email: $e');
    }
  }

  /// 4. Get AppUser by UserId
  Future<AppUser?> getAppUserById(String userId) async {
    // Add this method
    try {
      // Add this method
      final docSnapshot = await _userCollection.doc(userId).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        return AppUser.fromJson(data as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      // Add this method
      throw Exception('Failed to get user UID: $e');
    }
  }

// Fetch user data by email
  Future<AppUser?> getUserByEmail(String email) async {
    var cleanEmail = email.toLowerCase();
    try {
      // Query the userCollection for a document where the email field matches the provided email string
      final querySnapshot =
          await _userCollection.where('email', isEqualTo: cleanEmail).limit(1).get();

      if (querySnapshot.docs.isNotEmpty) {
        final docSnapshot = querySnapshot.docs.first;
        final data = docSnapshot.data();
        return AppUser.fromJson(data as Map<String, dynamic>);
      } else {
        // No user found with the provided email
        return null;
      }
    } catch (e) {
      // Handle errors as needed
      throw Exception('Failed to get user by email: $e');
    }
  }

  // Fetch user data by userId
  Future<AppUser?> getUserById(String userId) async {
    try {
      final docSnapshot = await _userCollection.doc(userId).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        return AppUser.fromJson(data as Map<String, dynamic>);
      } else {
        // User document does not exist
        return null;
      }
    } catch (e) {
      // Handle errors as needed
      throw Exception('Failed to get user UID: $e');
    }
  }

// Invite a new contact by email or add to contacts if the user already exists
  Future<void> inviteContact(String email, String currentUserUid) async {
    var cleanEmail = email.toLowerCase();
    try {
      // Get the current user's document reference
      final userRef = _userCollection.doc(currentUserUid);

      // Fetch the current user's data
      final docSnapshot = await userRef.get();
      if (!docSnapshot.exists) {
        throw Exception('Current user data not found.');
      }

      // Deserialize the current user data
      final data = docSnapshot.data()!;
      final currentUser = AppUser.fromJson(data as Map<String, dynamic>);

      // Search for the user by email in the userCollection
      final querySnapshot =
          await _userCollection.where('email', isEqualTo: cleanEmail).limit(1).get();

      if (querySnapshot.docs.isNotEmpty) {
        // User exists, add them to the current user's contacts list
        final existingUserDoc = querySnapshot.docs.first;
        final existingUserId =
            existingUserDoc.id; // The userId of the found user
        final existingUser =
            AppUser.fromJson(existingUserDoc.data() as Map<String, dynamic>);

        // Check if this user is already in the contacts list
        if (!currentUser.contacts.containsKey(existingUserId)) {
          // Add the user to contacts with their username
          currentUser.contacts[existingUserId] = existingUser.username;

          // Update Firestore with the new contacts list
          await userRef.update({
            'contacts': currentUser.contacts,
          });
          print('Added user ${existingUser.username} to contacts.');
        } else {
          print('User is already in contacts.');
        }
      } else {
        // User does not exist, add the email to the invitedContacts list
        if (!currentUser.invitedContacts.contains(cleanEmail)) {
          currentUser.invitedContacts.add(cleanEmail);

          // Update Firestore with the new invitedContacts list
          await userRef.update({
            'invitedContacts': currentUser.invitedContacts,
          });
          print('Added $cleanEmail to invited contacts.');
        } else {
          print('This email has already been invited.');
        }
      }
    } catch (e) {
      print('Error inviting contact: $e');
      rethrow; // Rethrow the exception to be handled by the caller
    }
  }

//Check current users invitedContacts to see if they are existing users yet, if so add them to contacts and remove them from invitedContacts
  Future<void> checkInvitedContacts(AppUser currentUser) async {
    try {
      // Fetch the current user's document reference
      final userRef = _userCollection.doc(currentUser.userId);
      // Fetch the current user's data
      final docSnapshot = await userRef.get();
      if (!docSnapshot.exists) {
        // If the user document does not exist, throw an exception
        throw Exception('Current user data not found.');
      } else {
        // Deserialize the current user data
        final data = docSnapshot.data()!;
        final currentUser = AppUser.fromJson(data as Map<String,
            dynamic>); // Create a new AppUser object from the data  // Check each email in the invitedContacts list
        for (var email in currentUser.invitedContacts) {
          // For each email, check if the user exists in the userCollection
          final querySnapshot = await _userCollection
              .where('email', isEqualTo: email)
              .limit(1)
              .get(); // Query the userCollection for a document where the email field matches the provided email string
          if (querySnapshot.docs.isNotEmpty) {
            // If the user document exists, add them to the current user's contacts list
            final existingUserDoc =
                querySnapshot.docs.first; // The userId of the found user
            final existingUserId =
                existingUserDoc.id; // The userId of the found user
            final existingUser = AppUser.fromJson(existingUserDoc.data() as Map<
                String, dynamic>); // Create a new AppUser object from the data
            if (!currentUser.contacts.containsKey(existingUserId)) {
              // If this user is not already in the contacts list
              currentUser.contacts[existingUserId] = existingUser
                  .username; // Add the user to contacts with their username
              currentUser.invitedContacts.remove(
                  email); // Remove the email from the invitedContacts list
              // Update Firestore with the new contacts list
              await userRef.update({
                'contacts': currentUser.contacts,
                'invitedContacts': currentUser.invitedContacts,
              });
              print('Added user ${existingUser.username} to contacts.');
              //TODO: Add a notification
            } else {
              // If this user is already in the contacts list
              currentUser.invitedContacts.remove(email);
              await userRef.update({
                'invitedContacts': currentUser.invitedContacts,
              });
              print('User is already in contacts.');
            } // If the user document does not exist, throw an exception
          } else {
            print('$email has not yet created an account');
          }
        } // For each email, check if the user exists in the userCollection
      } // Deserialize the current user data
    } catch (e) {
      // Handle errors as needed
      print('Error checking invited contacts: $e'); // Print the error message
      rethrow; // Rethrow the exception to be handled by the caller
    }
  }
}
