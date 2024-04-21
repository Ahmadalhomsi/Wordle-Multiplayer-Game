import 'package:flutter/material.dart';
import 'package:wordle/services/room_services.dart';
import 'package:wordle/utils/game_provider.dart';
import 'package:wordle/widgets/game_board.dart';

import '../models/Room.dart';

// ignore: must_be_immutable
class GameKeyboard extends StatefulWidget {
  int wordLength;
  Room room;
  String playerName;
  int playerType;
  GameKeyboard(
      this.game, this.wordLength, this.room, this.playerName, this.playerType,
      {super.key});
  WordleGame game;

  @override
  State<GameKeyboard> createState() =>
      _GameKeyboardState(wordLength, room, playerName, playerType);
}

String tempWord = ""; // to delete the character after indicating it

String replaceCharacterAtIndex(int index, String replacement, String word) {
  if (index < 0 || index >= word.length) {
    return word; // Index out of range, return the original word
  }

  // Replace the character at the specified index
  return word.replaceRange(index, index + 1, replacement);
}

bool characterExistsInWord(String character, String word) {
  for (int i = 0; i < word.length; i++) {
    if (word[i] == character) {
      tempWord = replaceCharacterAtIndex(i, "\$", tempWord);
      return true; // Character exists in the word
    }
  }
  return false; // Character does not exist in the word
}

class _GameKeyboardState extends State<GameKeyboard> {
  int wordLength;
  Room room;
  String playerName;
  int playerType;

  _GameKeyboardState(
      this.wordLength, this.room, this.playerName, this.playerType);

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
                    RoomService().uploadPlayerGuesses(
                        words, room.key, playerName, playerType);
                    print("---- Full word");

                    int yellowCount = 0;
                    int greenCount = 0;
                    tempWord = WordleGame.game_guess;

                    if (uGuess == WordleGame.game_guess) {
                      bool otherNotWon = true;
                      try {
                        otherNotWon = await RoomService()
                            .setTheWinner(room.key, playerName);
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
                      print("Checking");
                      for (int i = 0; i < uGuess.length; i++) {
                        String char = uGuess[i];
                        if (char == WordleGame.game_guess[i]) {
                          setState(() {
                            widget.game.wordleBoard[widget.game.rowId][i].code =
                                1;
                          });
                          greenCount++;
                          print("$greenCount GREENS");
                          tempWord = replaceCharacterAtIndex(i, "&", tempWord);
                        } else if (characterExistsInWord(char, tempWord)) {
                          setState(() {
                            widget.game.wordleBoard[widget.game.rowId][i].code =
                                2;
                          });
                          yellowCount++;
                          print("$yellowCount YELLOWS");
                        }
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
