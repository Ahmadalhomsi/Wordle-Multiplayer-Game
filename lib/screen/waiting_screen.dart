import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:wordle/screen/word_entry.dart';
import 'package:wordle/screen/rooms_browser.dart';

import 'game_screen.dart';

class WaitingScreen extends StatefulWidget {
  final Room room;

  const WaitingScreen({required this.room});

  @override
  _WaitingScreenState createState() => _WaitingScreenState(room);
}

class _WaitingScreenState extends State<WaitingScreen> {
  late DatabaseReference roomRef;
  Room room;
  _WaitingScreenState(this.room);

  @override
  void initState() {
    super.initState();
    roomRef =
        FirebaseDatabase.instance.ref().child('rooms').child(widget.room.key);
    roomRef.onValue.listen((event) {
      // Check if player 2 has joined the room
      if (event.snapshot.value != null) {
        print(event.snapshot.value); /////// heeeeeeeeer
        // Player 2 has joined, start the game (careful with null assertion!)
        if (room.type == 'User Input')
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => WordScreen(room: room),
            ),
          );
        else if (room.type == 'Random') {
          // generate the word here
          String randomWord = "random";
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => GameScreen(
                room: room,
                word: randomWord,
              ),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Build your waiting screen UI using the room object
    return Scaffold(
      appBar: AppBar(
        title: Text('Waiting Screen'),
      ),
      body: Center(
        child: Text('Waiting for another player in ${widget.room.name}'),
      ),
    );
  }
}
