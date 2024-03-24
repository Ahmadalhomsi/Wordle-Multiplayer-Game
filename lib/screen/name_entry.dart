import 'package:flutter/material.dart';
import 'package:wordle/screen/rooms_browser.dart';

class EnterNameScreen extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Your Name'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Enter Your Name',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the Room Browse screen and pass the entered name
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RoomBrowseScreen(
                      playerName: _nameController.text,
                    ),
                  ),
                );
              },
              child: Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: EnterNameScreen(),
  ));
}
