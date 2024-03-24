import 'package:flutter/material.dart';
import 'package:wordle/screen/game_screen.dart';

class WordScreen extends StatefulWidget {
  const WordScreen({Key? key}) : super(key: key);

  @override
  State<WordScreen> createState() => _WordScreenState();
}

class _WordScreenState extends State<WordScreen> {
  int _sliderValue = 4;
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
                        "$letter",
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
                  MaterialPageRoute(
                      builder: (context) =>
                          GameScreen(_sliderValue, letters.toString())),
                );
              },
              child: Text('Go to Another Screen'),
            ),
            SizedBox(
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
                    }
                    ;
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
