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
    try {
      String jsonGuesses = wordsToJson(guesses);

      // Upload the JSON data to Firebase under the respective node
      DatabaseReference reference = FirebaseDatabase.instance
          .ref()
          .child('rooms')
          .child(roomId)
          .child('player' + playerType.toString() + "_Guesses");
      reference.set(jsonGuesses);
    } catch (e) {
      print("error uploading player guesses");
    }
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
        'player1_Score': 0,
        'player2_Score': 0,
      });
      print("The room ${roomKey} has been reseted");
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
              resetRoom(roomId);
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

  Stream<bool> listenForOtherPlayerExistence(String roomId, int playerType) {
    DatabaseReference roomRef =
        FirebaseDatabase.instance.ref().child('rooms/$roomId');

    // Create a DataSnapshot stream for the room
    final roomStream = roomRef.onValue;

    return roomStream.map((event) {
      final snapshot = event.snapshot;
      if (snapshot.exists) {
        // Check for player1 or player2 based on the playerType
        if (playerType == 1) {
          String? player2 = snapshot.child('player2').value as String?;
          if (player2 == null) {
            print('Player 2 has left');
            return true; // Other player has left
          }
        } else if (playerType == 2) {
          String? player1 = snapshot.child('player1').value as String?;
          if (player1 == null) {
            print('Player 1 has left');
            return true; // Other player has left
          }
        }
      }
      return false; // Other player still exists
    });
  }

  Future<int> setPlayerScore(String roomId, int playerType, int score) async {
    try {
      DatabaseReference roomRef = databaseReference.child(roomId);
      DataSnapshot snapshot =
          await roomRef.child('player${playerType}_Score').get();

      if (snapshot.value == null || snapshot.value == 0) {
        await roomRef.child('player${playerType}_Score').set(score);
        print('score set.');
        return 1;
      } else {
        print('score is already set.');
        return 0;
      }
    } catch (error) {
      print('Error setting the Player Score');
      // Handle error accordingly
      return -1; // Return false in case of error
    }
    return -1;
  }

  Stream<int?> listenForOtherPlayerScore(String roomId, int playerType) {
    DatabaseReference roomRef =
        FirebaseDatabase.instance.ref().child('rooms/$roomId');

    // Create a DataSnapshot stream for the room
    final roomStream = roomRef.onValue;

    return roomStream.map((event) {
      try {
        final snapshot = event.snapshot;
        if (snapshot.exists) {
          // Check for player1 or player2 based on the playerType
          if (playerType == 1) {
            int? player2Score = snapshot.child('player2_Score').value as int?;
            if (player2Score == 0) {
              print('Player 2 has not finished yet');
            }
            return player2Score;
          } else if (playerType == 2) {
            int? player1Score = snapshot.child('player1_Score').value as int?;
            if (player1Score == 0) {
              print('Player 1 has not finished yet');
            }
            return player1Score;
          }
        }
      } catch (e) {
        print("Error listenForOtherPlayerScore" + e.toString());
      }

      return null; // Room or player not found
    });
  }

  Future<String> getOtherPlayerName(String roomId, int playerType) async {
    try {
      int otherPlayerType = (playerType == 1) ? 2 : 1;
      DatabaseReference roomRef = databaseReference.child(roomId);
      DataSnapshot snapshot =
          await roomRef.child('player$otherPlayerType').get();

      // Check if the snapshot value is not null before casting
      if (snapshot.value != null || snapshot.value != '') {
        return snapshot.value as String;
      } else {
        // Return an empty string if the snapshot value is null
        return '';
      }
    } catch (error) {
      print('Error getting other player name: $error');
      // Handle error accordingly
      return ''; // Return an empty string in case of error
    }
  }

  Future<List<String>?> getOtherPlayerGuesses(
      String roomId, int playerType) async {
    int otherPlayerType = (playerType == 1) ? 2 : 1;
    try {
      DatabaseReference roomRef = databaseReference.child(roomId);
      DataSnapshot snapshot =
          await roomRef.child('player${otherPlayerType}_Guesses').get();

      // Check if the snapshot value is not null before parsing
      if (snapshot.value != null) {
        // Parse the JSON string and explicitly cast each element to String
        List<String> guesses =
            (json.decode(snapshot.value!.toString()) as List<dynamic>)
                .map((dynamic item) => item.toString())
                .toList();
        return guesses;
      } else {
        // Return null if the snapshot value is null
        return null;
      }
    } catch (error) {
      print('Error getting other player guesses: $error');
      // Handle error accordingly
      return null;
    }
  }

// // Function to convert JSON string to List<String>
//   List<String> jsonToWords(dynamic json) {
//     List<dynamic> list = jsonDecode(json);
//     List<String> words = list.map((e) => e as String).toList();
//     return words;
//   }
}
