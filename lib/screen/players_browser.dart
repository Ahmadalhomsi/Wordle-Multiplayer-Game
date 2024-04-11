import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:wordle/screen/game_screen.dart';
import 'package:wordle/screen/room_maker.dart';
import 'package:wordle/screen/word_entry.dart';
import 'package:wordle/services/auth_service.dart';
import 'package:wordle/services/room_services.dart';

import '../models/Room.dart';
import 'waiting_screen.dart';

// Room browse screen widget
class PlayerBrowseScreen extends StatefulWidget {
  PlayerBrowseScreen();

  @override
  State<PlayerBrowseScreen> createState() => _PlayerBrowseScreenState();
}

class _PlayerBrowseScreenState extends State<PlayerBrowseScreen> {
  String? playerName;

  @override
  void initState() {
    super.initState();
    fetchPlayerName();
  }

  void fetchPlayerName() async {
    // Fetch playerName from Firebase
    User? user = AuthService().getXAuth().currentUser;
    setState(() {
      playerName = user?.displayName;
    });
  }

  final databaseReference = FirebaseDatabase.instance.ref();
  final DatabaseReference _userRef =
      FirebaseDatabase.instance.ref().child('users');
  final DatabaseReference _invitationsRef =
      FirebaseDatabase.instance.ref().child('invitations');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildPlayersList(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text('Players Browse - ${playerName ?? ""}'),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: fetchPlayerName,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
        ),
      ],
    );
  }

  Widget _buildPlayersList() {
    return FutureBuilder(
      future: _fetchPlayers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          List<Map<String, String>> players =
              snapshot.data as List<Map<String, String>>;
          return ListView.builder(
            itemCount: players.length,
            itemBuilder: (context, index) {
              String playerName = players[index]['name']!;
              String playerStatus = players[index]['status']!;
              String playerId = players[index]['id']!;
              return ListTile(
                title: Text(playerName),
                subtitle: Text(playerStatus),
                // You can display player statuses here
                // Example:
                leading: Icon(playerStatus == 'Online'
                    ? Icons.online_prediction_rounded
                    : Icons.offline_bolt_rounded),
                trailing: IconButton(
                  icon: Icon(Icons.person_add),
                  onPressed: () {
                    // Implement your logic for inviting this player
                    // Store the invitation in the database
                    sendInvitation(playerId);
                  },
                ),
              );
            },
          );
        }
      },
    );
  }

  Future<void> sendInvitation(String recipientId) async {
    try {
      // Get the current user's ID
      String? currentUserId = AuthService().getXAuth().currentUser?.uid;
      // Store the invitation in the database directly under the receiver's ID
      await _invitationsRef.child(recipientId).set({
        'senderId': currentUserId,
        //'receiverId': recipientId,
        'sentAt': DateTime.now().millisecondsSinceEpoch,
      });
      // Show a snackbar to indicate that the invitation was sent
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invitation sent to $recipientId'),
        ),
      );
    } catch (error) {
      print('Error sending invitation: $error');
    }
  }

  Future<List<Map<String, String>>> _fetchPlayers() async {
    List<Map<String, String>> players = [];

    try {
      DataSnapshot snapshot = await _userRef.get();
      if (snapshot.exists) {
        Map<dynamic, dynamic>? usersMap =
            snapshot.value as Map<dynamic, dynamic>?;

        if (usersMap != null) {
          usersMap.forEach((key, value) {
            String? playerName = value['name'];
            String? playerStatus = value['status'];
            String? playerId = key;
            if (playerName != null &&
                playerStatus != null &&
                playerId != null) {
              players.add(
                  {'name': playerName, 'status': playerStatus, 'id': playerId});
            }
          });
        }
      } else {
        print('No players found in the database.');
      }
    } catch (error) {
      print('Error fetching players: $error');
      // Handle error accordingly
    }

    return players;
  }
}
