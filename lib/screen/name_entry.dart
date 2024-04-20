import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wordle/screen/room_options.dart';

import 'package:wordle/screen/rooms_browser.dart';

import '../services/auth_service.dart';
import '../services/auth_service.dart';
import '../services/user_services.dart'; // Import EnterNameScreen

class EnterNameScreen extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  var user;
  EnterNameScreen({super.key});

  @override
  Future<void> initState() async {
    final result = await FirebaseAuth.instance.signInAnonymously();
    user = result.user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Name'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 25.0), // Add padding here
            child: IconButton(
              icon: const Icon(Icons.logout),
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
              decoration: const InputDecoration(
                labelText: 'Enter Your Name',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final User? u = AuthService().getXAuth().currentUser;
                // Get the user ID of the current user
                String? userId = u?.uid;

                // Update the display name in Firebase Authentication
                if (userId != null) {
                  await u?.updateDisplayName(_nameController.text);
                }

                UserService().addUserIfNotExists(userId!, _nameController.text,
                    'Online', ['User Input', '0']);
                // Navigate to the Room Browse screen and pass the entered name
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RoomOptionsScreen(_nameController.text),
                  ),
                );
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}
