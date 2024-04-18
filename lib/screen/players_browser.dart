import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:wordle/screen/game_screen.dart';
import 'package:wordle/screen/room_maker.dart';
import 'package:wordle/screen/word_entry.dart';
import 'package:wordle/services/auth_service.dart';
import 'package:wordle/services/room_services.dart';

import '../models/Room.dart';
import '../services/invitation_listener.dart';
import 'waiting_screen.dart';

// Room browse screen widget
class PlayerBrowseScreen extends StatefulWidget {
  final String gameType;
  final String wordLength;

  const PlayerBrowseScreen(
      {required this.gameType, required this.wordLength, super.key});

  @override
  State<PlayerBrowseScreen> createState() =>
      _PlayerBrowseScreenState(this.gameType, this.wordLength);
}

class _PlayerBrowseScreenState extends State<PlayerBrowseScreen> {
  String? playerName;

  String gameType;
  String wordLength;

  late List<String> roomSettings;
  _PlayerBrowseScreenState(this.gameType, this.wordLength);

  StreamSubscription<bool>? _invitationStreamSubscription;

  @override
  void initState() {
    super.initState();
    roomSettings = [];
    fetchPlayerName();
    roomSettings.add(gameType);
    roomSettings.add(wordLength);
    print("My room settings:" + roomSettings.toString());
    String userId = AuthService().getXAuth().currentUser!.uid;

    ///**** listenning */
    final listener = InvitationListener(userId);

    final StreamSubscription<String?> _invitationStreamSubscription =
        listener.listenForInvitations().listen((senderId) {
      if (senderId != null) {
        print("You have a new invitation from $senderId!");
        // Handle invitation logic here (show notification, navigate to invitation screen)
//            _invitationStreamSubscription?.cancel(); // Consider using this cautiously
        showInvitationDialog(senderId).then((accept) {
          if (accept != null) {
            if (accept) {
              // Handle accept logic (call your function here)
            } else {
              // Reject invitation
              rejectInvitation(senderId);
              //print("invitation rejected");
            }
          }
        });
      } else {
        print("No new invitations yet.");
      }
    });
    ////*** End of listenning */

    print("Started Listenning for: " + userId);
  }

  @override
  void dispose() {
    _invitationStreamSubscription?.cancel(); // Clean up listener on dispose
    super.dispose();
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

  void ss(String currentUserId) {
    DatabaseReference invitationsRef =
        FirebaseDatabase.instance.ref().child('invitations');

    invitationsRef.onChildAdded.listen((event) {
      // Extract invitation details
      Map<dynamic, dynamic>? invitationMap =
          event.snapshot.value as Map<dynamic, dynamic>?;
      if (invitationMap != null) {
        String receiverId = invitationMap['receiverId'];
        String senderId = invitationMap['senderId'];
        String sentAt = invitationMap['sentAt'];

        // Check if the current user is the receiver
        if (receiverId == currentUserId) {
          // Check if the sender is a valid user
          DatabaseReference userRef =
              FirebaseDatabase.instance.ref().child('users').child(senderId);
          userRef
              .once()
              .then((DataSnapshot snapshot) {
                if (snapshot.exists) {
                  // The sender is a valid user
                  // Handle the invitation here
                } else {
                  // The sender does not exist in the database
                  print('Invalid sender: $senderId');
                }
              } as FutureOr Function(DatabaseEvent value))
              .catchError((error) {
            print('Error checking sender: $error');
          });
        }
      }
    });
  }

  Future<bool?> showInvitationDialog(String invitationId) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Invitation'),
        content: Text('Do you want to accept this invitation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true), // Accept
            child: Text('Accept'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Reject
            child: Text('Reject'),
          ),
        ],
      ),
    );
  }

  Future<void> rejectInvitation(String invitationId) async {
    try {
      // Get a reference to the specific invitation
      final invitationRef = _invitationsRef.child(invitationId);

      // Delete the invitation at the given ID
      await invitationRef.remove();

      // Show a snackbar to indicate that the invitation was rejected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invitation rejected'),
        ),
      );
    } catch (error) {
      print('Error rejecting invitation: $error');
    }
  }
}
