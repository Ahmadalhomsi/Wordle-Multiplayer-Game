import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wordle/screen/rooms_browser.dart';

import '../services/auth_service.dart';

class EnterNameScreen extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Name'),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.0), // Add padding here
            child: IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                AuthService().signOut();
              },
            ),
          ),
        ],
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
              onPressed: () async {
                final User? u = AuthService().getXAuth().currentUser;
                // Get the user ID of the current user
                String? userId = u?.uid;

                // Update the display name in Firebase Authentication
                if (userId != null) {
                  await u?.updateDisplayName(_nameController.text);
                }

                // Navigate to the Room Browse screen and pass the entered name
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RoomBrowseScreen(),
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
