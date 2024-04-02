import 'package:flutter/material.dart';
import 'package:wordle/screen/rooms_browser.dart';

import 'package:wordle/utils/game_provider.dart';
import 'package:wordle/widgets/game_keyboard.dart';

import '../models/Room.dart';

class GameScreen extends StatefulWidget {
  final Room room;
  final String word;
  GameScreen({required this.room, required this.word, super.key});

  @override
  State<GameScreen> createState() => _GameScreenState(room, word);
}

class _GameScreenState extends State<GameScreen> {
  Room room;
  String word;
  _GameScreenState(this.room, this.word);

// Take the other word from the other player

  late final WordleGame _game;

  @override
  void initState() {
    super.initState();
    _game = WordleGame(room.wordLength, word, 2); // 1 Random, 2 User Input
    print("The word:" + word);
    print("Word Length :" + room.wordLength.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //1et's start create the basic layout of the app
        backgroundColor: const Color(0xFF212121),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'wordle',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            GameKeyboard(_game),
          ],
        ));
  }
}
