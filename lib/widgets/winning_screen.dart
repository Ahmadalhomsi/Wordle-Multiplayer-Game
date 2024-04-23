import 'package:flutter/material.dart';
import 'package:wordle/screen/room_options.dart';

class WinningScreen extends StatelessWidget {
  final String playerName;
  final int playerScore;
  final String opponentName;
  final int opponentScore;
  final String message;

  WinningScreen(
      {required this.playerName,
      required this.playerScore,
      required this.opponentName,
      required this.opponentScore,
      required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[800],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$message, $playerName!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Text(
              '$message with a score of $playerScore!',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Opponent: $opponentName',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            Text(
              'Opponent Score: $opponentScore',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RoomOptionsScreen(
                        playerName), // Replace with your Room Settings screen
                  ),
                );
              },
              child: Text('Back to Game'),
            ),
          ],
        ),
      ),
    );
  }
}
