import 'package:flutter/material.dart';
import 'package:wordle/screen/game_screen.dart';

class WordScreen extends StatefulWidget {
  const WordScreen({Key? key}) : super(key: key);

  @override
  State<WordScreen> createState() => _WordScreenState();
}

class _WordScreenState extends State<WordScreen> {
  int _sliderValue = 4;
  List<String> letters =
      "ABCDEFGHIJKLMNOPQRSTUVWXYZ".split(""); // Generate letters from A to Z

  List<String> userTypedWord = List.generate(
      7, (index) => ""); // Initialize user typed word list with empty strings

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF212121),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: letters.take(_sliderValue).map((letter) {
                return InkWell(
                  onTap: () {
                    // Handle user tapping on the letter
                    setState(() {
                      // Add the tapped letter to the userTypedWord list
                      userTypedWord.add(letter);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    width: 64.0, // Adjust this width as needed
                    height: 64.0, // Adjust this height as needed
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.grey.shade800,
                    ),
                    child: Center(
                      child: Text(
                        userTypedWord.isEmpty
                            ? letter
                            : userTypedWord[
                                0], // Display the typed letter if present
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(
              height: 30.0,
            ),
            Slider(
              value: _sliderValue.toDouble(),
              min: 4,
              max: 7,
              divisions: 3,
              onChanged: (newValue) {
                setState(() {
                  _sliderValue = newValue.toInt();
                });
              },
            ),
            Text(
              'Word size: $_sliderValue',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GameScreen(_sliderValue)),
                );
              },
              child: Text('Go to Another Screen'),
            ),
          ],
        ),
      ),
    );
  }
}
