import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wordle/services/room_services.dart';
import 'package:wordle/utils/game_provider.dart';
import 'package:wordle/widgets/game_board.dart';

import '../models/Room.dart';
import 'winning_screen.dart';

// ignore: must_be_immutable
class GameKeyboard extends StatefulWidget {
  int wordLength;
  Room room;
  String playerName;
  int playerType;
  String otherPlayerName;

  GameKeyboard(this.game, this.wordLength, this.room, this.playerName,
      this.playerType, this.otherPlayerName,
      {super.key});
  WordleGame game;

  @override
  State<GameKeyboard> createState() => _GameKeyboardState(
        wordLength,
        room,
        playerName,
        playerType,
        otherPlayerName,
      );
}

String tempWord = ""; // to delete the character after indicating it

String replaceCharacterAtIndex(int index, String replacement, String word) {
  if (index < 0 || index >= word.length) {
    return word; // Index out of range, return the original word
  }

  // Replace the character at the specified index
  return word.replaceRange(index, index + 1, replacement);
}

int characterExistsInWord(String character, String word) {
  for (int i = 0; i < word.length; i++) {
    if (word[i] == character) {
      tempWord = replaceCharacterAtIndex(i, "\$", tempWord);
      return i; // Character exists in the word
    }
  }
  return -1; // Character does not exist in the word
}

class _GameKeyboardState extends State<GameKeyboard> {
  int wordLength;
  Room room;
  String playerName;
  int playerType;
  String otherPlayerName;

  _GameKeyboardState(
    this.wordLength,
    this.room,
    this.playerName,
    this.playerType,
    this.otherPlayerName,
  );

  List<String> words = [];

  List row1 = "QWERTYUIOP".split("");
  List row2 = "ASDEFGHJKL".split("");
  List row3 = ["DEL", "Z", "X", "C", "V", "B", "N", "M", "SUBMIT"];

  late Timer _timer;
  int _secondsRemaining = 10; // 10 seconds
  int totalRemainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void randomWordEntry() {
    // Generate a random word entry
    // You can use any method to generate a random word
    // For example, you can use a list of predefined words and select one randomly
    List<String> sourceList = [
      'apple',
      'banana',
      'orange',
      'grape',
      'kiwi',
      'melon',
      'peach',
      'pear',
      'plum',
      'lemon',
      'berry',
      'cherry',
      'mango',
      'ale',
      'lager',
      'stout',
      'pilsner',
      'ipa',
      'wheat',
      'pale',
      'porter',
      'truffle',
      'porcini',
      'shiitake',
      'cremini',
      'oyster',
      'maitake',
      'morel',
      'enoki',
      'button',
      'bread',
      'toast',
      'bagel',
      'muffin',
      'panini',
      'sandwich',
      'wrap',
      'burger',
      'taco',
      'burrito',
      'quesadilla',
      'enchilada',
      'nachos',
      'empanada',
      'tamale',
      'fajita',
      'guacamole',
      'salsa',
      'queso',
      'chorizo',
      'carnitas',
      'barbacoa',
      'refried',
      'black',
      'pinto',
      'chickpea',
      'lentil',
      'hummus',
      'falafel',
      'tabbouleh',
      'shawarma',
      'gyro',
      'souvlaki',
    ];

    // Filter words from the list that match the desired length
    final wordList =
        sourceList.where((word) => word.length == wordLength).toList();

    String randomWord = wordList[Random().nextInt(wordList.length)];

    randomWord.runes.forEach((int rune) {
      var character = new String.fromCharCode(rune);
      otherButtonsImpl(character.toUpperCase());
    });

    widget.game.letterId = wordLength;
    setState(() {
      submitButtonImpl("SUBMIT");
    });

    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          timer.cancel();
          // Execute specific process when the timer reaches 0 seconds
          print("Timer finished");
          randomWordEntry(); // Call the function to generate a random word entry
        }
      });
    });
  }

  void resetTimer() {
    setState(() {
      _secondsRemaining = 10; // Reset timer to 10 minutes
    });
  }

  void pauseTimer() {
    _timer.cancel();
  }

  void stopTimer() {
    _timer.cancel();
    setState(() {
      _secondsRemaining = 0; // Stop timer and set remaining seconds to 0
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      // Game Logic

      // The keyboard
      children: [
        ElevatedButton(
          onPressed: () async {
            // Call the function to get the other player's guesses
            List<String>? otherPlayerGuesses =
                await RoomService().getOtherPlayerGuesses(room.key, playerType);

            // Check if otherPlayerGuesses is not null
            if (otherPlayerGuesses != null) {
              // Open a popup or dialog to display the other player's guesses
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Other Player\'s Guesses'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: otherPlayerGuesses
                          .map((guess) => Text(guess))
                          .toList(),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        child: Text('Close'),
                      ),
                    ],
                  );
                },
              );
            } else {
              // Handle the case where otherPlayerGuesses is null
              // Display a message or take appropriate action
            }
          },
          child: Text('Show Other Player\'s Guesses'),
        ),
        const SizedBox(
          height: 20.0,
        ),
        Text(
          'Timer: $_secondsRemaining',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        const SizedBox(
          height: 20.0,
        ),
        Text(
          WordleGame.game_message,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        const SizedBox(
          height: 20.0,
        ),
        GameBoard(widget.game), // the squares
        const SizedBox(
          height: 40.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: row1.map((e) {
            return InkWell(
              onTap: () {
                otherButtonsImpl(e);
              },
              child: Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.grey.shade300),
                child: Text(
                  "$e",
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(
          height: 10.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: row2.map((e) {
            return InkWell(
              onTap: () {
                otherButtonsImpl(e);
              },
              child: Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.grey.shade300),
                child: Text(
                  "$e",
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(
          height: 10.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: row3.map((e) {
            return InkWell(
              onTap: () async {
                print(e + widget.game.letterId.toString());
                if (e == "DEL") {
                  if (widget.game.letterId > 0) {
                    setState(() {
                      widget.game
                          .insertWord(widget.game.letterId - 1, Letter("", 0));
                      widget.game.letterId--;
                    });
                  }
                } else if (e == "SUBMIT") {
                  submitButtonImpl(e);
                } else {
                  if (widget.game.letterId < wordLength) {
                    setState(() {
                      widget.game
                          .insertWord(widget.game.letterId, Letter(e, 0));
                      widget.game.letterId++;
                    });
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.grey.shade300),
                child: Text(
                  "$e",
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void otherButtonsImpl(String e) {
    print(e + widget.game.letterId.toString());
    if (widget.game.letterId < wordLength) {
      setState(() {
        widget.game.insertWord(widget.game.letterId, Letter(e, 0));
        widget.game.letterId++;
      });
    }
  }

  Future<void> submitButtonImpl(String e) async {
    if (widget.game.letterId >= wordLength) {
      String uGuess = widget.game.wordleBoard[widget.game.rowId] // user's guess
          .map((e) => e.letter)
          .join();
      print("---- Uploading word");
      words.add(uGuess);
      try {
        RoomService()
            .uploadPlayerGuesses(words, room.key, playerName, playerType);
      } catch (e) {
        print("Error uploading player guesses");
      }

      print("---- Full word");

      tempWord = WordleGame.game_guess;
      int yellowCount = 0;
      int greenCount = 0;
      totalRemainingSeconds += _secondsRemaining;
      print("total time:" + totalRemainingSeconds.toString());
      resetTimer();

      if (uGuess == WordleGame.game_guess) {
        // All are equal
        bool otherNotWon = true;
        try {
          otherNotWon = await RoomService().setTheWinner(room.key, playerName);
          await RoomService()
              .setPlayerScore(room.key, playerType, 10 * wordLength);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WinningScreen(
                playerName: playerName,
                playerScore: 10 * wordLength + totalRemainingSeconds,
                opponentName: otherPlayerName,
                opponentScore: 0,
                message: "Congratulations",
              ),
            ),
          );
        } catch (e) {
          print("Error setting the winner: " + e.toString());
        }

        setState(() {
          if (otherNotWon) {
            WordleGame.game_message = "Congratulations, You won!!";
          } else {
            WordleGame.game_message = "Other player won before you";
          }
          for (var element in widget.game.wordleBoard[widget.game.rowId]) {
            element.code = 1;
          }
        });
        greenCount = uGuess.length;
      } else {
        print("Checking " +
            widget.game.rowId.toString() +
            " " +
            uGuess.length.toString());
        for (int i = 0; i < uGuess.length; i++) {
          String char = uGuess[i];
          int index = characterExistsInWord(char, tempWord);
          if (char == WordleGame.game_guess[i]) {
            setState(() {
              widget.game.wordleBoard[widget.game.rowId][i].code = 1;
            });
            greenCount++;
            tempWord = replaceCharacterAtIndex(i, "&", tempWord);
          } else if ((index != -1) &&
              (uGuess[index] != WordleGame.game_guess[index])) {
            setState(() {
              widget.game.wordleBoard[widget.game.rowId][i].code = 2;
            });
            yellowCount++;
          }
        }
        if ((widget.game.rowId + 1) == uGuess.length) {
          print("End of laaast chance");
          print("$greenCount GREENS");
          print("$yellowCount YELLOWS");
          int myScore =
              (greenCount * 10 + yellowCount * 5 + totalRemainingSeconds);
          print("Score: " + myScore.toString());

          await RoomService().setPlayerScore(room.key, playerType, myScore);

          StreamSubscription<int?>? subscription;
          int otherPlayerScore = 0;

          // Start listening to the stream
          Future.delayed(Duration(seconds: 2), () async {
            subscription = RoomService()
                .listenForOtherPlayerScore(room.key, playerType)
                .listen((score) async {
              if (score != -1) {
                // Score is not null, handle the score
                print('Other player score: $score');
                otherPlayerScore = score!;

                if (myScore > score) {
                  print("You are the winner");
                  await RoomService().setTheWinner(room.key, playerName);
                  await RoomService()
                      .setPlayerScore(room.key, playerType, myScore);

                  subscription?.cancel();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WinningScreen(
                        playerName: playerName,
                        playerScore: myScore,
                        opponentName: otherPlayerName,
                        opponentScore: score,
                        message: "Congratulations",
                      ),
                    ),
                  );
                } else if (myScore == score) {
                  subscription?.cancel();
                  await RoomService()
                      .setPlayerScore(room.key, playerType, myScore);
                  print("Draw");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Draw'),
                    ),
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WinningScreen(
                        playerName: playerName,
                        playerScore: myScore,
                        opponentName: otherPlayerName,
                        opponentScore: score,
                        message: "Draw",
                      ),
                    ),
                  );
                } else {
                  subscription?.cancel();
                  await RoomService()
                      .setPlayerScore(room.key, playerType, myScore);
                  print("The other player is the winner");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WinningScreen(
                        playerName: playerName,
                        playerScore: myScore,
                        opponentName: otherPlayerName,
                        opponentScore: score,
                        message: "You lost",
                      ),
                    ),
                  );
                }

                subscription?.cancel();
                // You can do further processing here if needed
              } else {
                // Score is null, indicate that the other player has not finished yet
                print('Waiting for the other player to finish...');
              }
            });
          });

          print("Enderista");
          pauseTimer();

          // Example of cancelling the subscription after some time (optional)
          // Future.delayed(Duration(minutes: 5), () {
          //   subscription?.cancel();
          // });
          ///// print("**** " + otherPlayerScore);
        }
      }
      if ((yellowCount == 0) && (greenCount == 0)) {
        setState(() {
          WordleGame.game_message = "the wordle does not exist try again";
        });
        print(WordleGame.game_message);
      }
      widget.game.rowId++;
      widget.game.letterId = 0;
    }
  }
}
