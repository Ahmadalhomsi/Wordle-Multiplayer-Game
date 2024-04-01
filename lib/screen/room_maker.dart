import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:wordle/models/Room.dart';
import 'package:wordle/screen/rooms_browser.dart';
import 'package:wordle/models/Room.dart'
    as RoomModel; // Rename the import using 'as' prefix

import '../services/room_services.dart';

class RoomMaker extends StatefulWidget {
  final String userName;
  final databaseReference;
  const RoomMaker(this.userName, this.databaseReference, {super.key});

  @override
  State<RoomMaker> createState() =>
      _RoomMakerState(userName, databaseReference);
}

class _RoomMakerState extends State<RoomMaker> {
  final String userName;
  final databaseReference;
  final databaseReference2 = FirebaseDatabase.instance.ref();
  _RoomMakerState(this.userName, this.databaseReference);

  String _roomName = '';
  String _roomType = 'Random'; // Default to Random
  int _wordLength = 4; // Default word length

  final List<String> roomTypes = ['Random', 'User Input'];

  @override
  Widget build(BuildContext context) {
    Future<void> createRoom(RoomModel.Room room) async {
      try {
        await databaseReference.child('rooms').push().set(room.toMap());
      } catch (error) {
        print('Error creating room: $error');
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF212121),
      appBar: AppBar(
        title:
            Text('Rooms Browse - $userName'), // Show player name in the title
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Room Name:',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                onChanged: (value) {
                  setState(() {
                    _roomName = value;
                  });
                },
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade300,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Room Type:',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField(
                value: _roomType,
                onChanged: (value) {
                  setState(() {
                    _roomType = value.toString();
                  });
                },
                items: roomTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text(
                'Word Length:',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Slider(
                value: _wordLength.toDouble(),
                min: 4,
                max: 7,
                divisions: 3,
                label: _wordLength.toString(),
                onChanged: (value) {
                  setState(() {
                    _wordLength = value.round();
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Create a Room object with user input
                  RoomModel.Room room = RoomModel.Room(
                    name: _roomName,
                    type: _roomType,
                    isFull: false, // Assuming the room is initially not full
                    wordLength: _wordLength, key: '',
                  );
                  // Call the createRoom method to add the room to the database
                  createRoom(room as RoomModel.Room);
                  // Navigate back to the RoomBrowseScreen
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RoomBrowseScreen(),
                    ),
                    ModalRoute.withName(
                        '/'), // Removes all the intermediate routes
                  );
                },
                child: const Text('Create Room'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/*
ElevatedButton(
              onPressed: () {
                // Navigate to the RoomBrowseScreen and pass the player name
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RoomBrowseScreen(),
                  ),
                  ModalRoute.withName(
                      '/'), // Removes all the intermediate routes
                );
              },
              child: const Text('Create Room'),
            ),
*/