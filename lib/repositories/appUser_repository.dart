import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guide_solve/models/appUser.dart';

class AppUserRepository {
    final CollectionReference _userCollection = FirebaseFirestore.instance.collection('users');

// Fetch user data by email
Future<AppUser?> getUserByEmail(String email) async {
  try {
    // Query the userCollection for a document where the email field matches the provided email string
    final querySnapshot = await _userCollection.where('email', isEqualTo: email).limit(1).get();
    
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
    final querySnapshot = await _userCollection.where('email', isEqualTo: email).limit(1).get();

    if (querySnapshot.docs.isNotEmpty) {
      // User exists, add them to the current user's contacts list
      final existingUser = querySnapshot.docs.first;
      final existingUserId = existingUser.id; // The userId of the found user

      // Check if this user is already in the contacts list
      if (!currentUser.contacts.contains(existingUserId)) {
        currentUser.contacts.add(existingUserId);

        // Update Firestore with the new contacts list
        await userRef.update({
          'contacts': currentUser.contacts,
        });
        print('Added user $existingUserId to contacts.');
      } else {
        print('User is already in contacts.');
      }
    } else {
      // User does not exist, add the email to the invitedContacts list
      if (!currentUser.invitedContacts.contains(email)) {
        currentUser.invitedContacts.add(email);

        // Update Firestore with the new invitedContacts list
        await userRef.update({
          'invitedContacts': currentUser.invitedContacts,
        });
        print('Added $email to invited contacts.');
      } else {
        print('This email has already been invited.');
      }
    }

  } catch (e) {
    print('Error inviting contact: $e');
    rethrow; // Rethrow the exception to be handled by the caller
  }
}

}
