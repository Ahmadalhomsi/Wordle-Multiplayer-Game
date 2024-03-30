import 'package:flutter/material.dart';
import 'package:wordle/screen/authentication/authenticate.dart';
import 'package:wordle/screen/home/home.dart';
import 'package:wordle/screen/name_entry.dart';

import '../models/user.dart';
import '../services/auth_service.dart'; // Import EnterNameScreen

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key});

  @override
  Widget build(BuildContext context) {
    // Return either Home or Authenticate widget
    return StreamBuilder<UserX?>(
      stream: AuthService().userZ,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator if the authentication state is loading
          return CircularProgressIndicator();
        } else {
          // Check if the user is authenticated
          if (snapshot.hasData) {
            // If authenticated, navigate to EnterNameScreen
            return EnterNameScreen(); // Assuming EnterNameScreen is properly implemented
          } else {
            // If not authenticated, show the authentication flow
            return Authenticate();
          }
        }
      },
    );
  }
}
