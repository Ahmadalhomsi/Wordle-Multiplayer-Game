import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:wordle/screen/word_entry.dart';
import 'package:wordle/screen/rooms_browser.dart';

import '../models/Room.dart';
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
      var snapshotValue = event.snapshot.value;

      if (snapshotValue != null) {
        Map<String, dynamic> snapshotMap = {};
        String keyString = '';
        (snapshotValue as Map<Object?, Object?>).forEach((key, value) {
          if (key != null) {
            keyString = key.toString();
            snapshotMap[keyString] = value;
          }
        });

        Room r = Room.fromJson(snapshotMap, widget.room.key);

        // Check if player2 has entered the room
        if (r.player2 != null && r.player2!.isNotEmpty) {
          // Player 2 has joined, start the game
          if (r.type == 'User Input') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => WordScreen(room: room),
              ),
            );
          } else if (r.type == 'Random') {
            // Generate the word here
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
        } else {
          // Player 2 hasn't joined yet, continue waiting
          print("Player 2 hasn't joined yet.");
        }
      } else {
        print("Data snapshot is null.");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
