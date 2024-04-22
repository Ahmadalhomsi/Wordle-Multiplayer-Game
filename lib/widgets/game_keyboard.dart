import 'dart:async';

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
      wordLength, room, playerName, playerType, otherPlayerName);
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

  _GameKeyboardState(this.wordLength, this.room, this.playerName,
      this.playerType, this.otherPlayerName);

  List<String> words = [];

  List row1 = "QWERTYUIOP".split("");
  List row2 = "ASDEFGHJKL".split("");
  List row3 = ["DEL", "Z", "X", "C", "V", "B", "N", "M", "SUBMIT"];

  @override
  Widget build(BuildContext context) {
    return Column(
      // Game Logic

      // The keyboard
      children: [
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
                print(e + widget.game.letterId.toString());
                if (widget.game.letterId < wordLength) {
                  setState(() {
                    widget.game.insertWord(widget.game.letterId, Letter(e, 0));
                    widget.game.letterId++;
                  });
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
        const SizedBox(
          height: 10.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: row2.map((e) {
            return InkWell(
              onTap: () {
                print(e + widget.game.letterId.toString());
                if (widget.game.letterId < wordLength) {
                  setState(() {
                    widget.game.insertWord(widget.game.letterId, Letter(e, 0));
                    widget.game.letterId++;
                  });
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
                  if (widget.game.letterId >= wordLength) {
                    String uGuess = widget
                        .game.wordleBoard[widget.game.rowId] // user's guess
                        .map((e) => e.letter)
                        .join();
                    print("---- Uploading word");
                    words.add(uGuess);
                    try {
                      RoomService().uploadPlayerGuesses(
                          words, room.key, playerName, playerType);
                    } catch (e) {
                      print("Error uploading player guesses");
                    }

                    print("---- Full word");

                    tempWord = WordleGame.game_guess;
                    int yellowCount = 0;
                    int greenCount = 0;

                    if (uGuess == WordleGame.game_guess) {
                      bool otherNotWon = true;
                      try {
                        otherNotWon = await RoomService()
                            .setTheWinner(room.key, playerName);
                        await RoomService().setPlayerScore(
                            room.key, playerType, 10 * wordLength);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WinningScreen(
                              playerName: playerName,
                              playerScore: 10 * wordLength,
                              opponentName: otherPlayerName,
                              opponentScore: 0,
                            ),
                          ),
                        );
                      } catch (e) {
                        print("Error setting the winner: " + e.toString());
                      }

                      setState(() {
                        if (otherNotWon) {
                          WordleGame.game_message =
                              "Congratulations, You won!!";
                        } else {
                          WordleGame.game_message =
                              "Other player won before you";
                        }
                        for (var element
                            in widget.game.wordleBoard[widget.game.rowId]) {
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
                            widget.game.wordleBoard[widget.game.rowId][i].code =
                                1;
                          });
                          greenCount++;
                          tempWord = replaceCharacterAtIndex(i, "&", tempWord);
                        } else if ((index != -1) &&
                            (uGuess[index] != WordleGame.game_guess[index])) {
                          setState(() {
                            widget.game.wordleBoard[widget.game.rowId][i].code =
                                2;
                          });
                          yellowCount++;
                        }
                      }
                      if ((widget.game.rowId + 1) == uGuess.length) {
                        print("End of laaast chance");
                        print("$greenCount GREENS");
                        print("$yellowCount YELLOWS");
                        int myScore = (greenCount * 10 + yellowCount * 5);
                        print("Score: " + myScore.toString());

                        await RoomService()
                            .setPlayerScore(room.key, playerType, myScore);

                        StreamSubscription<int?>? subscription;
                        int otherPlayerScore = 0;

                        // Start listening to the stream
                        subscription = RoomService()
                            .listenForOtherPlayerScore(room.key, playerType)
                            .listen((score) async {
                          if (score != 0) {
                            // Score is not null, handle the score
                            print('Other player score: $score');
                            otherPlayerScore = score!;

                            if (myScore > score) {
                              print("You are the winner");
                              await RoomService()
                                  .setTheWinner(room.key, playerName);
                              await RoomService().setPlayerScore(
                                  room.key, playerType, myScore);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WinningScreen(
                                    playerName: playerName,
                                    playerScore: myScore,
                                    opponentName: otherPlayerName,
                                    opponentScore: score,
                                  ),
                                ),
                              );
                            } else if (myScore == score) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Draw'),
                                ),
                              );
                            } else {
                              print("The other player is the winner");
                            }

                            subscription?.cancel();
                            // You can do further processing here if needed
                          } else {
                            // Score is null, indicate that the other player has not finished yet
                            print('Waiting for the other player to finish...');
                          }
                        });

                        print("Enderista");

                        // Example of cancelling the subscription after some time (optional)
                        // Future.delayed(Duration(minutes: 5), () {
                        //   subscription?.cancel();
                        // });
                        ///// print("**** " + otherPlayerScore);
                      }
                    }
                    if ((yellowCount == 0) && (greenCount == 0)) {
                      setState(() {
                        WordleGame.game_message =
                            "the wordle does not exist try again";
                      });
                      print(WordleGame.game_message);
                    }
                    widget.game.rowId++;
                    widget.game.letterId = 0;
                  }
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
}
