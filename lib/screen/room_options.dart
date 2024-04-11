import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:wordle/models/user.dart';
import 'package:wordle/screen/players_browser.dart';
import 'package:wordle/screen/rooms_browser.dart';

import 'package:wordle/screen/waiting_screen.dart';
import 'package:wordle/services/auth_service.dart';

import '../models/Room.dart';
import '../services/room_services.dart';

class RoomOptionsScreen extends StatefulWidget {
  final String name;

  RoomOptionsScreen(this.name);

  @override
  _RoomOptionsScreenState createState() => _RoomOptionsScreenState(this.name);
}

class _RoomOptionsScreenState extends State<RoomOptionsScreen> {
  String _selectedGameType = 'Random'; // Default game type
  int _selectedWordLength = 4; // Default word length
  List<Room> _filteredRooms = []; // Filtered rooms based on selection
  //String? playerName;
  List<Room> rooms = []; // List to hold fetched rooms
  final String name;
  UserX? user;

  _RoomOptionsScreenState(this.name);

  @override
  void initState() {
    super.initState();
    setupUser();
    //fetchPlayerName();
    fetchRooms(); // Fetch rooms when the screen loads
  }

  void setupUser() async {
    // Fetch playerName from Firebase
    user = AuthService().globalUser;
    print("Setuping UserId" + user!.uid.toString());
    user!.name = this.name;
    user!.status = 'Online';
  }

  // void fetchPlayerName() async {
  //   // Fetch playerName from Firebase
  //   User? user = AuthService().getXAuth().currentUser;
  //   setState(() {
  //     playerName = user?.displayName;
  //   });
  // }

  final databaseReference = FirebaseDatabase.instance.ref();

  void fetchRooms() async {
    List<Room> fetchedRooms = (await RoomService().getRooms()).cast<Room>();
    setState(() {
      rooms = fetchedRooms;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Room Selection'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0), // Add padding around the elements
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DropdownButtonFormField(
              value: _selectedGameType,
              onChanged: (value) {
                setState(() {
                  _selectedGameType = value.toString();
                });
              },
              items: ['Random', 'User Input'].map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Slider(
              value: _selectedWordLength.toDouble(),
              min: 4,
              max: 7,
              divisions: 3,
              onChanged: (value) {
                setState(() {
                  _selectedWordLength = value.toInt();
                });
              },
            ),
            SizedBox(height: 20),
            Text(
              'Selected Word Length: $_selectedWordLength',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Filter rooms based on selected game type and word length
                _filterRooms();
                // Automatically select and enter the player into the first room in the filtered list
                _enterRoomAutomatically();
              },
              child: Text('OK'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the room browser screen for manual room browsing
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RoomBrowseScreen(),
                  ),
                );
              },
              child: Text('Browse Rooms Manually'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the room browser screen for manual room browsing
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlayerBrowseScreen(),
                  ),
                );
              },
              child: Text('Browse Players Manually'),
            ),
          ],
        ),
      ),
    );
  }

  // Function to filter rooms based on selected game type and word length
  void _filterRooms() {
    // Implement logic to filter rooms based on selected game type and word length
    // For example, you can fetch rooms from Firebase and filter them here
    // Sample logic:
    _filteredRooms = rooms
        .where((room) =>
            room.type == _selectedGameType &&
            room.wordLength == _selectedWordLength)
        .toList();
  }

  // Function to automatically enter the player into the first room in the filtered list
  void _enterRoomAutomatically() {
    if (_filteredRooms.isNotEmpty) {
      // Navigate to the waiting screen for automatic room entry
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WaitingScreen(
            room: _filteredRooms.first,
            playerName: name!,
          ),
        ),
      );
    } else {
      // Display a message indicating no rooms match the selected criteria
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No rooms match the selected criteria.'),
        ),
      );
    }
  }
}
