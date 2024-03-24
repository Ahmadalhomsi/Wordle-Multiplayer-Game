import 'package:flutter/material.dart';
import 'package:wordle/utils/game_provider.dart';
import 'package:wordle/widgets/game_keyboard.dart';

class GameScreen extends StatefulWidget {
  int sliderValue;
  String gameWord;
  GameScreen(this.sliderValue, this.gameWord, {super.key});

  @override
  State<GameScreen> createState() => _GameScreenState(sliderValue);
}

class _GameScreenState extends State<GameScreen> {
  int sliderValue = 7;
  _GameScreenState(this.sliderValue);

// Take the other word from the other player

  late final WordleGame _game;

  @override
  void initState() {
    super.initState();
    _game = WordleGame(sliderValue, "BRAIN", 2); // 1 Random, 2 User Input
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
