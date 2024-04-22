import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:wordle/services/room_services.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _userRef =
      FirebaseDatabase.instance.ref().child('users');
  final DatabaseReference _invitationRef =
      FirebaseDatabase.instance.ref().child('invitations');

  // Function to add a new user to the database if not already exists and update the name
  Future<void> addUserIfNotExists(
      String uid, String name, String status, List<String> roomSettings) async {
    try {
      DatabaseReference userRef = _userRef.child(uid);
      DataSnapshot snapshot = await userRef.get();

      if (!snapshot.exists) {
        await userRef.set({
          'name': name,
          'status': status,
          'roomSettings': roomSettings,
          // Add any other user details you want to store
        });
        print('User $name added with UID: $uid');
      } else {
        // User exists, check if the name is different
        Map<dynamic, dynamic>? userData =
            snapshot.value as Map<dynamic, dynamic>?;
        if (userData != null) {
          String storedName = userData['name'];
          if (name != storedName) {
            // Update the user's name in the database
            await userRef.child('name').set(name);
            print('User $uid name updated to $name');
          } else {
            print('User $name with UID: $uid already exists');
          }
        }
      }
    } catch (error) {
      print('Error adding user: $error');
      // Handle error accordingly
    }
  }

  Future<void> updateUserStatus(String uid, String status) async {
    try {
      DatabaseReference userRef = _userRef.child(uid);
      await userRef.child('status').set(status);
      print('User $uid status updated to $status');
    } catch (error) {
      print('Error updating user status: $error');
      // Handle error accordingly
    }
  }

  Future<void> updateUserRoomSettings(
      String uid, List<String> roomSettings) async {
    try {
      DatabaseReference userRef = _userRef.child(uid);
      await userRef.child('roomSettings').set(roomSettings);
      print('User $uid room settings updated to $roomSettings');
    } catch (error) {
      print('Error updating user room settings: $error');
      // Handle error accordingly
    }
  }

  // Update user's name and status
  Future<void> updateUser(String uid, String name, String status) async {
    await _userRef.child(uid).update({'name': name, 'status': status});
  }

  // Fetch user details from Firebase Realtime Database
  Future<Object?> fetchUserDetails(String uid) async {
    DataSnapshot snapshot = (await _userRef.child(uid).once()) as DataSnapshot;
    return snapshot.value;
  }

  // Invite user to a room
  Future<void> inviteToRoom(
      String inviterUid, String invitedUid, String roomId) async {
    // Add invitation to the invited user
    await _invitationRef.child(invitedUid).child(roomId).set(true);
  }

  // Accept invitation to a room
  Future<void> acceptInvitation(
      String userId, String playerName, String roomId) async {
    // Add user to the room members
    //await _roomRef.child(roomId).child('members').child(userId).set(true);
    RoomService().joinRoom(roomId, playerName);

    // Remove the invitation
    await _invitationRef.child(userId).child(roomId).remove();
  }

  String generateRandomWord(int length) {
    final random = Random();

    // List of words with lengths between 4 and 7 characters
    final wordList = [
      'apple',
      'banana',
      'orange',
      'grape',
      'melon',
      'peach',
      'pear',
      'kiwi',
      'plum',
      'button',
      'bread',
      'toast',
      'black',
      'burger',
      'mango',
    ];

    // Filter words from the list that match the desired length
    final filteredWords =
        wordList.where((word) => word.length == length).toList();

    // If there are no words of the desired length, return an empty string
    if (filteredWords.isEmpty) {
      return '';
    }

    // Choose a random word from the filtered list
    return filteredWords[random.nextInt(filteredWords.length)];
  }
}
