import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:wordle/models/Room.dart'
    as RoomModel; // Rename the import using 'as' prefix
import 'package:wordle/screen/rooms_browser.dart';

import '../models/Room.dart';

class RoomService {
  final databaseReference = FirebaseDatabase.instance.ref().child('rooms');

  // Function to convert list of words into a JSON format
  String wordsToJson(List<String> words) {
    // Convert the list of words into a JSON array
    return json.encode(words);
  }

// Upload player guesses to Firebase
  void uploadPlayerGuesses(
      List<String> guesses, String roomId, String player, int playerType) {
    String jsonGuesses = wordsToJson(guesses);

    // Upload the JSON data to Firebase under the respective node
    DatabaseReference reference = FirebaseDatabase.instance
        .ref()
        .child('rooms')
        .child(roomId)
        .child('player' + playerType.toString() + "_Guesses");
    reference.set(jsonGuesses);
  }

  Future<void> resetRoom(String roomKey) async {
    try {
      await databaseReference.child(roomKey).update({
        'player1': '',
        'player2': '',
        'player1Word': '',
        'player2Word': '',
        'isFull': false,
        'winner': '',
        'player1_Guesses': '',
        'player2_Guesses': '',
      });
    } catch (error) {
      print('Error resetting room: $error');
    }
  }

  Future<List<Room>> getRooms() async {
    List<Room> rooms = [];

    try {
      final snapshot = await databaseReference.get();
      if (snapshot.exists) {
        final data =
            snapshot.value as Map<dynamic, dynamic>; // Explicit cast to Map
        data.forEach((key, value) {
          final room = Room(
            name: value['name'],
            type: value['type'],
            isFull: value['isFull'],
            wordLength: value['wordLength'],
            key: key,
          );
          rooms.add(room);
        });
      } else {
        print('No data available.');
      }
      return rooms;
    } catch (error) {
      print('Error fetching rooms: $error');
      return [];
    }
  }

  Future<void> createRoom(RoomModel.Room room) async {
    // Use the RoomModel prefix
    try {
      await databaseReference.child('rooms').push().set(room.toMap());
    } catch (error) {
      print('Error creating room: $error');
    }
  }

  Future<int> joinRoom(String roomId, String playerName) async {
    try {
      print("joining Room: " + roomId + " by" + playerName);
      DatabaseReference roomRef = databaseReference.child(roomId);
      DataSnapshot snapshot = await roomRef.get();
      if (snapshot.exists) {
        Map<dynamic, dynamic>? roomData =
            snapshot.value as Map<dynamic, dynamic>?;
        if (roomData != null) {
          // Check if the room is not full
          if (!roomData['isFull']) {
            // Check if player1 is empty
            if (roomData['player1'] == null || roomData['player1'] == '') {
              await roomRef.update({'player1': playerName});
              print('Player $playerName joined room $roomId as player1');
              return 0;
            }
            // Check if player2 is empty
            else if (roomData['player2'] == null || roomData['player2'] == '') {
              await roomRef.update({'player2': playerName, 'isFull': true});
              print('Player $playerName joined room $roomId as player2');
              return 1;
            }
          } else {
            print('Room $roomId is already full');
          }
        } else {
          print('Room data is null or invalid');
        }
      } else {
        print('Room $roomId does not exist');
      }
    } catch (error, stackTrace) {
      print('Error joining room: $error');
      print('Stack trace: $stackTrace');
    }
    return -99;
  }

  Stream<DatabaseEvent> getRoomStream(String roomId) {
    // Construct a database reference to the specific room
    DatabaseReference roomRef = FirebaseDatabase.instance.ref('rooms/$roomId');

    // Return a stream of database events (such as data changes) for the room reference
    return roomRef.onValue;
  }

  Future<Room?> findAvailableRoom(String type, String wordLength) async {
    DatabaseReference roomsRef = FirebaseDatabase.instance.ref().child('rooms');

    try {
      DataSnapshot snapshot = await roomsRef.get();
      if (snapshot.exists) {
        Map<dynamic, dynamic>? roomsMap =
            snapshot.value as Map<dynamic, dynamic>?;

        if (roomsMap != null) {
          for (var entry in roomsMap.entries) {
            String roomId = entry.key;
            Map<dynamic, dynamic>? roomData =
                entry.value as Map<dynamic, dynamic>?;

            if (roomData != null &&
                roomData['isFull'] == true &&
                roomData['type'] == type &&
                roomData['wordLength'] == int.parse(wordLength)) {
              // Reset room if not empty
              await resetRoom(roomId);
              Room xroom = Room(
                  key: roomId,
                  name: roomData['name'],
                  type: type,
                  isFull: false,
                  wordLength: int.parse(wordLength));
              return xroom;
            } else if (roomData != null &&
                roomData['isFull'] == false &&
                roomData['type'] == type &&
                roomData['wordLength'] == int.parse(wordLength)) {
              // Reset room if not empty
              Room xroom = Room(
                  key: roomId,
                  name: roomData['name'],
                  type: type,
                  isFull: false,
                  wordLength: int.parse(wordLength));
              return xroom;
            }
          }
        }
      } else {
        print('No rooms found in the database.');
      }
    } catch (error) {
      print('Error finding available room: $error');
      // Handle error accordingly
    }
  }

  Future<Room?> getRoomById(String roomId) async {
    DatabaseReference roomRef =
        FirebaseDatabase.instance.ref().child('rooms').child(roomId);

    try {
      DataSnapshot snapshot = await roomRef.get();
      if (snapshot.exists) {
        Map<dynamic, dynamic>? roomData =
            snapshot.value as Map<dynamic, dynamic>?;

        if (roomData != null) {
          String type = roomData['type'];
          String name = roomData['name'];
          bool isFull = roomData['isFull'];
          int wordLength = roomData['wordLength'];

          // Create and return the Room object
          Room room = Room(
            key: roomId,
            name: name,
            type: type,
            isFull: isFull,
            wordLength: wordLength,
          );
          return room;
        }
      } else {
        print('Room with ID $roomId not found in the database.');
      }
    } catch (error) {
      print('Error getting room with ID $roomId: $error');
      // Handle error accordingly
    }

    return null; // Return null if the room is not found or if there's an error
  }

  Future<void> leaveRoom(String roomId, String playerName) async {
    try {
      DatabaseReference roomRef = databaseReference.child(roomId);
      DataSnapshot snapshot = await roomRef.get();
      if (snapshot.exists) {
        Map<dynamic, dynamic>? roomData =
            snapshot.value as Map<dynamic, dynamic>?;
        if (roomData != null) {
          // Check if the player is in the room
          if (roomData['player1'] == playerName) {
            await roomRef.update({'player1': ''});
            print('Player $playerName left room $roomId');
          } else if (roomData['player2'] == playerName) {
            await roomRef.update({'player2': '', 'isFull': false});
            print('Player $playerName left room $roomId');
          } else {
            print('Player $playerName is not in room $roomId');
          }
        } else {
          print('Room data is null or invalid');
        }
      } else {
        print('Room $roomId does not exist');
      }
    } catch (error, stackTrace) {
      print('Error leaving room: $error');
      print('Stack trace: $stackTrace');
    }
  }

  Future<bool> setTheWinner(String roomId, String playerName) async {
    try {
      DatabaseReference roomRef = databaseReference.child(roomId);
      DataSnapshot snapshot = await roomRef.child('winner').get();

      if (snapshot.value == null || snapshot.value == '') {
        await roomRef.child('winner').set(playerName);
        print('$playerName Wins.');
        return true; // Winner was set successfully
      } else {
        print('Winner is already set.');
        try {
          resetRoom(roomId);
        } catch (e) {
          print("Error reseting the room in the setTheWinner func");
        }

        return false; // Winner already exists
      }
    } catch (error) {
      print('Error setting the winner: $error');
      // Handle error accordingly
      return false; // Return false in case of error
    }
  }
}
