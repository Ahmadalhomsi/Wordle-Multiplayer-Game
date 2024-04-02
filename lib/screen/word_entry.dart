import 'package:flutter/material.dart';
import 'package:wordle/screen/game_screen.dart';
import 'package:wordle/screen/rooms_browser.dart';

import '../models/Room.dart';

class WordScreen extends StatefulWidget {
  final Room room;
  const WordScreen({required this.room, super.key});

  @override
  State<WordScreen> createState() => _WordScreenState(room);
}

class _WordScreenState extends State<WordScreen> {
  Room room;
  int _sliderValue = 4;
  _WordScreenState(this.room);

  @override
  void initState() {
    super.initState();
    _sliderValue = room.wordLength;
  }

  List row1 = "QWERTYUIOP".split("");
  List row2 = "ASDEFGHJKL".split("");
  List row3 = ["DEL", "Z", "X", "C", "V", "B", "N", "M", "SUBMIT"];

  List<String> letters = "       ".split(""); // Generate letters from A to Z
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF212121),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Room Name',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
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
            ElevatedButton(
              onPressed: () {
                String wd = "";
                for (int i = 0; i < room.wordLength; i++) {
                  wd += letters[i];
                }
                //print("XXXXXXXXXX: $wd");

                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => GameScreen(
                            room: room,
                            word: wd,
                          )),
                );
              },
              child: const Text('Go to Another Screen'),
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
                  onTap: () {
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
                      } else {
                        print(e + index.toString());
                        if (index < _sliderValue) {
                          setState(() {
                            letters[index] = e;
                            index++;
                          });
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
    );
  }
}
