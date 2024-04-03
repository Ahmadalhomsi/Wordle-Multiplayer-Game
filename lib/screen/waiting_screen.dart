import 'dart:async';
import 'dart:html';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:wordle/screen/word_entry.dart';
import 'package:wordle/screen/rooms_browser.dart';

import '../models/Room.dart';
import 'game_screen.dart';

class WaitingScreen extends StatefulWidget {
  final Room room;
  final String playerName;
  const WaitingScreen({required this.room, required this.playerName});

  @override
  _WaitingScreenState createState() => _WaitingScreenState(room, playerName);
}

class _WaitingScreenState extends State<WaitingScreen> {
  late DatabaseReference roomRef;
  final String playerName;
  var cancelation;

  Room room;

  _WaitingScreenState(this.room, this.playerName);

  @override
  void initState() {
    super.initState();
    roomRef = FirebaseDatabase.instance.ref(
        'rooms/${widget.room.key}'); // or .ref().child('rooms').child(widget.room.key);
    print("Before listenning");
    cancelation = roomRef.onValue.listen((event) {
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

        Room r = room.roomFromJson(snapshotMap, widget.room.key);
        // Check if player2 has entered the room
        if (r.player2 != null && r.player2!.isNotEmpty) {
          // Player 2 has joined, start the game
          if (r.type == 'User Input') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => WordScreen(
                  room: room,
                  playerName: playerName,
                  playerType: 1,
                ),
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
                  playerName: playerName,
                  playerType: 1,
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
  void dispose() {
    super.dispose();
    print("Disposed");
    cancelation.cancel(); // Stop listening when the state is disposed
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
