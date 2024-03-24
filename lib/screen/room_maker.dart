import 'package:flutter/material.dart';
import 'package:wordle/screen/game_screen.dart';
import 'package:wordle/screen/rooms_browser.dart';

class RoomMaker extends StatefulWidget {
  const RoomMaker({Key? key}) : super(key: key);

  @override
  State<RoomMaker> createState() => _RoomMakerState();
}

class _RoomMakerState extends State<RoomMaker> {
  int _sliderValue = 4;
  List row1 = "QWERTYUIOP".split("");
  List row2 = "ASDEFGHJKL".split("");
  List row3 = ["DEL", "Z", "X", "C", "V", "B", "N", "M", "SUBMIT"];

  TextEditingController _roomNameController = TextEditingController();
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
            Text(
              'Room Name:',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            TextField(
              controller: _roomNameController,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade300,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(
              height: 30.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: row1.map((e) {
                return InkWell(
                  onTap: () {
                    print(e + index.toString());

                    setState(() {
                      _roomNameController.text += e;
                      index++;
                    });
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

                    setState(() {
                      _roomNameController.text += e;
                      index++;
                    });
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
                          _roomNameController.text = _roomNameController.text
                              .substring(
                                  0, _roomNameController.text.length - 1);
                          index--;
                        });
                      }
                    } else if (e == "SUBMIT") {}
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
            SizedBox(
              height: 20.0,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RoomBrowseScreen(), // GameScreen(_sliderValue, _roomNameController.text)
                  ),
                ).then((_) {
                  // Code to execute after navigating back from GameScreen
                  // For example, you can print a message
                  print('Navigation to GameScreen completed.');
                });
              },
              child: Text('Create Room'),
            ),
          ],
        ),
      ),
    );
  }
}
