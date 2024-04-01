import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:wordle/screen/game_screen.dart';
import 'package:wordle/screen/room_maker.dart';
import 'package:wordle/screen/word_entry.dart';
import 'package:wordle/services/auth_service.dart';
import 'package:wordle/services/room_services.dart';

import 'waiting_screen.dart';

// Define a data model for a room
class Room {
  final String key;
  final String name;
  final String type;
  final bool isFull;
  final int wordLength; // Add wordLength property

  Room({
    required this.key,
    required this.name,
    required this.type,
    required this.isFull,
    required this.wordLength, // Initialize wordLength property
  });
}

// Room browse screen widget
class RoomBrowseScreen extends StatefulWidget {
  RoomBrowseScreen();

  @override
  State<RoomBrowseScreen> createState() => _RoomBrowseScreenState();
}

class _RoomBrowseScreenState extends State<RoomBrowseScreen> {
  String? playerName;
  List<Room> rooms = []; // List to hold fetched rooms

  @override
  void initState() {
    super.initState();
    fetchPlayerName();
    fetchPlayerName2();
    fetchRooms(); // Fetch rooms when the screen loads
  }

  void fetchPlayerName() async {
    // Fetch playerName from Firebase
    User? user = AuthService().getXAuth().currentUser;
    setState(() {
      playerName = user?.displayName;
    });
  }

  final databaseReference = FirebaseDatabase.instance.ref();

  void fetchPlayerName2() async {
    // Fetch playerName from Firebase
    // Code for fetching playerName goes here
  }

  void fetchRooms() async {
    List<Room> fetchedRooms = (await RoomService().getRooms()).cast<Room>();
    setState(() {
      rooms = fetchedRooms;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filter rooms by word length (minimum 4, maximum 7)
    List<Room> filteredRooms = rooms
        .where((room) => room.wordLength >= 4 && room.wordLength <= 7)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Rooms Browse - ${playerName}'), // Show player name in the title
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 20.0), // Adjust the padding as needed
            child: TextButton(
              onPressed: () {
                // Handle pressing the "Create Room" button
                print('Create Room button pressed');
                // Navigate to the room maker screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RoomMaker(playerName!, databaseReference),
                  ),
                );
              },
              child: Text(
                'Create Room',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16, // Adjust the font size as needed
                  color: Colors.blueGrey[900], // Set the text color
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: rooms.length,
        separatorBuilder: (BuildContext context, int index) {
          return Divider(
            height: 0,
            color: Colors.grey[400],
            thickness: 0.5,
          );
        },
        itemBuilder: (context, index) {
          Room room = rooms[index]; // Use filtered rooms
          return ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            title: Text(
              room.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      room.type == 'Random'
                          ? Icons.casino_rounded
                          : Icons.keyboard_rounded,
                      color: room.type == 'Random' ? Colors.blue : Colors.green,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      room.type,
                      style: TextStyle(
                        color:
                            room.type == 'Random' ? Colors.blue : Colors.green,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  room.isFull ? 'Status: Full' : 'Status: Empty',
                  style: TextStyle(
                    color: room.isFull ? Colors.red : Colors.green,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4), // Add some spacing
                Text(
                  'Word Length: ${room.wordLength}',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            onTap: () async {
              // Handle tapping on a room, such as navigating to room details screen
              print('Tapped on room: ${room.name}');

              // Allow the player to join the room
              int hasJoined =
                  await RoomService().joinRoom(room.key, playerName!) as int;
              print("ZZZZZZZZZZZZZZ:" + hasJoined.toString());
              if (hasJoined == 1) {
                // Navigate to the WaitingScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WaitingScreen(room: room),
                  ),
                );
              } else if (hasJoined == 2) {
                // Navigate to the GameScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WordScreen(room: room),
                  ),
                );
              } else {
                print("Joining failed");
              }
            },
          );
        },
      ),
    );
  }
}
