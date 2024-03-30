import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wordle/screen/room_maker.dart';
import 'package:wordle/services/auth_service.dart';

// Define a data model for a room
class Room {
  final String name;
  final String type;
  final bool isFull;

  Room({required this.name, required this.type, required this.isFull});
}

// Sample data for rooms
List<Room> rooms = [
  Room(name: 'Room 1', type: 'Random', isFull: false),
  Room(name: 'Room 2', type: 'User Input', isFull: true),
  Room(name: 'Room 3', type: 'Random', isFull: false),
  // Add more room objects as needed
];

// Room browse screen widget
class RoomBrowseScreen extends StatefulWidget {
  RoomBrowseScreen();

  @override
  State<RoomBrowseScreen> createState() => _RoomBrowseScreenState();
}

class _RoomBrowseScreenState extends State<RoomBrowseScreen> {
  String? playerName;

  @override
  void initState() {
    super.initState();
    fetchPlayerName();
  }

  void fetchPlayerName() async {
    // Fetch playerName from Firebase
    User? user = AuthService().getXAuth().currentUser;
    setState(() {
      playerName = user?.displayName;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    builder: (context) => RoomMaker(playerName!),
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
          Room room = rooms[index];
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
              ],
            ),
            onTap: () {
              // Handle tapping on a room, such as navigating to room details screen
              print('Tapped on room: ${room.name}');
            },
          );
        },
      ),
    );
  }
}
