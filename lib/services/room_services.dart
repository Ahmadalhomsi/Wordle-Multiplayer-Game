import 'package:firebase_database/firebase_database.dart';
import 'package:wordle/models/Room.dart'
    as RoomModel; // Rename the import using 'as' prefix
import 'package:wordle/screen/rooms_browser.dart';

class RoomService {
  final databaseReference = FirebaseDatabase.instance.ref().child('rooms');

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
              return 1;
            }
            // Check if player2 is empty
            else if (roomData['player2'] == null || roomData['player2'] == '') {
              await roomRef.update({'player2': playerName, 'isFull': true});
              print('Player $playerName joined room $roomId as player2');
              return 2;
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
    } catch (error) {
      print('Error joining room: $error');
    }
    return 0;
  }

  Stream<DatabaseEvent> getRoomStream(String roomId) {
    // Construct a database reference to the specific room
    DatabaseReference roomRef = FirebaseDatabase.instance.ref('rooms/$roomId');

    // Return a stream of database events (such as data changes) for the room reference
    return roomRef.onValue;
  }
}
