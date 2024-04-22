import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wordle/screen/game_screen.dart';
import 'package:wordle/screen/room_options.dart';
import 'package:wordle/screen/rooms_browser.dart';
import 'package:wordle/services/room_services.dart';

import '../models/Room.dart';

class WordScreen extends StatefulWidget {
  final Room room;
  final String playerName;
  final int playerType;
  const WordScreen(
      {required this.room, required this.playerName, required this.playerType});

  @override
  State<WordScreen> createState() =>
      _WordScreenState(room, playerName, playerType);
}

class _WordScreenState extends State<WordScreen> {
  final Room room;
  int _sliderValue = 4;
  final String playerName;
  final int playerType;
  late Timer _timer;
  int _secondsRemaining = 60; // Initial value for timer display

  _WordScreenState(this.room, this.playerName, this.playerType);

  @override
  void initState() {
    super.initState();
    _sliderValue = room.wordLength;
    // Start the timer when the widget initializes
    _startTimer();
  }

  // Function to start the timer
  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _secondsRemaining--;
      });
      // Call xx function if the button is not pressed within 1 minute
      if (_secondsRemaining <= 0) {
        xx();
        _cancelTimer();
      }
    });
  }

  // Function to cancel the timer
  void _cancelTimer() {
    _timer.cancel();
  }

  // Function to reset the timer
  void _resetTimer() {
    _cancelTimer();
    setState(() {
      _secondsRemaining = 60;
    });
    _startTimer();
  }

  // xx function (for testing)
  Future<void> xx() async {
    print('Timer expired, xx function called!');
    print(playerName + ' has been kicked');
    try {
      await RoomService().leaveRoom(room.key, playerName);
    } catch (e) {
      print("Error leaving the room");
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RoomOptionsScreen(playerName),
      ),
    );
  }

  List row1 = "QWERTYUIOP".split("");
  List row2 = "ASDEFGHJKL".split("");
  List row3 = ["DEL", "Z", "X", "C", "V", "B", "N", "M", "SUBMIT"];

  List<String> letters = "       ".split(""); // Generate letters from A to Z
  int index = 0;

  String waitingMessage = '';

  @override
  void dispose() {
    _cancelTimer(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF212121),
        body: Stack(children: [
          Positioned(
            top: 10,
            right: 10,
            child: Text(
              '$_secondsRemaining seconds remaining',
              style: TextStyle(
                color: Colors.yellow,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '$waitingMessage',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Text(
                  room.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                // Display the timer with yellow text

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: letters.take(_sliderValue).map((letter) {
                    return InkWell(
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        width: 64.0, // Adjust this width as needed
                        height: 64.0, // Adjust this height as needed
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: Colors.grey.shade300,
                        ),
                        child: Center(
                          // Center the text horizontally and vertically
                          child: Text(
                            letter,
                            style: const TextStyle(
                              fontSize: 30.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(
                  height: 30.0,
                ),
                Text(
                  'Word size: $_sliderValue',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),

                const SizedBox(
                  height: 20.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: row1.map((e) {
                    return InkWell(
                      onTap: () {
                        print(e + index.toString());
                        if (index < _sliderValue) {
                          setState(() {
                            letters[index] = e;
                            index++;
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
                        print(e + index.toString());
                        if (index < _sliderValue) {
                          setState(() {
                            letters[index] = e;
                            index++;
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
                        print(e + index.toString());
                        if (e == "DEL") {
                          if (index > 0) {
                            setState(() {
                              letters[index] = " ";
                              index--;
                            });
                          }
                        } else if (e == "SUBMIT") {
                          if (index >= _sliderValue) {
                            String wd = "";
                            for (int i = 0; i < room.wordLength; i++) {
                              if (letters[i] == '') {
                                print("***** Short word *****");
                                return null;
                              }

                              wd += letters[i];
                            }
                            //print("XXXXXXXXXX: $wd");
                            room.updatePlayerWord(wd, playerType);
                            print("++++________++++");
                            String wordToGuess = '';
                            int otherPlayer = playerType == 1 ? 2 : 1;

                            if (playerType == 1) {
                              // ScaffoldMessenger.of(context).showSnackBar(
                              //   const SnackBar(
                              //     content: Row(
                              //       children: [
                              //         CircularProgressIndicator(),
                              //         SizedBox(width: 16),
                              //         Text(
                              //             'Please wait for the other player to enter the word.'),
                              //       ],
                              //     ),
                              //     duration: Duration(
                              //         seconds:
                              //             5), // Adjust the duration as needed
                              //   ),
                              // );
                            }
                            setState(() {
                              waitingMessage =
                                  'Please wait for the other player to enter the word.';
                            });
                            _cancelTimer();

                            wordToGuess = await room.listenForPlayerWordChanges(
                                'player$otherPlayer');
                            room.playerWordChangesListener.cancel();

                            // Do something with the updated word
                            print('Player${otherPlayer}\'s word: $wordToGuess');

                            print("++++________++++" + wordToGuess);
                            print("YESSSSSSSSSSSSSSSSSSS");

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GameScreen(
                                        room: room,
                                        word: wordToGuess,
                                        playerName: playerName,
                                        playerType: playerType,
                                      )),
                            );
                          } else {
                            print(e + index.toString());
                            if (index < _sliderValue) {
                              print("Submit button");
                            }
                          }
                        } else {
                          if (index < _sliderValue) {
                            setState(() {
                              letters[index] = e;
                              index++;
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
            ),
          ),
        ]));
  }
}
