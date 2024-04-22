import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wordle/screen/players_browser.dart';
import 'package:wordle/screen/room_options.dart';
import 'package:wordle/screen/rooms_browser.dart';
import 'package:wordle/services/room_services.dart';

import 'package:wordle/utils/game_provider.dart';
import 'package:wordle/widgets/game_keyboard.dart';

import '../models/Room.dart';

class GameScreen extends StatefulWidget {
  final Room room;
  final String word;
  final String playerName;
  final int playerType;

  GameScreen({
    required this.room,
    required this.word,
    required this.playerName,
    required this.playerType,
    super.key,
  });

  @override
  State<GameScreen> createState() => _GameScreenState(
        room,
        word,
        playerName,
        playerType,
      );
}

class _GameScreenState extends State<GameScreen> {
  Room room;
  String word;
  String playerName;
  int playerType;
  int triesCount = 3;

  _GameScreenState(
    this.room,
    this.word,
    this.playerName,
    this.playerType,
  );

  late final WordleGame _game;
  late StreamSubscription<bool?> _invitationStreamSubscription;

  @override
  void initState() {
    super.initState();
    _game = WordleGame(room.wordLength, word, 2, triesCount);
    print("The word:" + word);
    print("Word Length :" + room.wordLength.toString());

    ///**** listenning */
    _invitationStreamSubscription = RoomService()
        .listenForOtherPlayerExistence(room.key, playerType)
        .listen((playerLeft) {
      // the senderId is also the invitation ID
      if (playerLeft) {
        print("The other player has left");
      } else {
        print("Other player exists.");
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    room.removePlayerFromRoom(playerName);
  }

  Future<void> _confirmExit(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Exit'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to exit?'),
                Text('You will lose if you exit.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Exit'),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RoomOptionsScreen(playerName),
                  ),
                  ModalRoute.withName(
                      '/'), // Removes all the intermediate routes
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF212121),
      appBar: AppBar(
        title: Text(playerName),
        automaticallyImplyLeading: false, // Remove back button
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              _confirmExit(context); // Show confirmation dialog
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Guess the word',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 20.0,
          ),
          GameKeyboard(_game, word.length, room, playerName, playerType),
        ],
      ),
    );
  }
}
