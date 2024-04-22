import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:wordle/screen/game_screen.dart';
import 'package:wordle/screen/room_maker.dart';
import 'package:wordle/screen/word_entry.dart';
import 'package:wordle/services/auth_service.dart';
import 'package:wordle/services/room_services.dart';
import 'package:wordle/services/user_services.dart';

import '../models/Room.dart';
import '../services/invitation_listener.dart';
import 'waiting_screen.dart';

// Room browse screen widget
class PlayerBrowseScreen extends StatefulWidget {
  final String gameType;
  final String wordLength;
  final String playerName;

  const PlayerBrowseScreen(
      {required this.playerName,
      required this.gameType,
      required this.wordLength,
      super.key});

  @override
  State<PlayerBrowseScreen> createState() =>
      _PlayerBrowseScreenState(this.playerName, this.gameType, this.wordLength);
}

class _PlayerBrowseScreenState extends State<PlayerBrowseScreen> {
  String? playerName;

  String gameType;
  String wordLength;
  String userId = AuthService().getXAuth().currentUser!.uid;

  _PlayerBrowseScreenState(this.playerName, this.gameType, this.wordLength);

  late StreamSubscription<String?> _invitationStreamSubscription;

  @override
  void initState() {
    super.initState();

    print("My room settings: " + gameType + ", " + wordLength);

    ///**** listenning */
    final listener = InvitationListener(userId);

    _invitationStreamSubscription =
        listener.listenForInvitations().listen((senderId) {
      // the senderId is also the invitation ID
      if (senderId != null) {
        print("You have a new invitation from $senderId!");
        // Handle invitation logic here (show notification, navigate to invitation screen)
//            _invitationStreamSubscription?.cancel(); // Consider using this cautiously
        Duration timeout = Duration(seconds: 10);

        showInvitationDialogWithTimeout(senderId, timeout).then((accept) {
          if (accept != null) {
            if (accept) {
              // Handle accept logic (call your function here)
              acceptInvitation(senderId, userId, gameType, wordLength);
              _invitationStreamSubscription.cancel();
            } else {
              // Reject invitation
              rejectInvitation(senderId);

              // Show a snackbar to indicate that the invitation was rejected
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Invitation rejected'),
                ),
              );
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
    //UserService().updateUserStatus(userId, 'Offline');
    super.dispose();
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
          onPressed: () {
            setState(() {});
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
        ),
      ],
    );
  }

  Widget _buildPlayersList() {
    return FutureBuilder(
      future: _fetchPlayers([gameType, wordLength]),
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
                    sendInvitation(playerId, gameType);
                  },
                ),
              );
            },
          );
        }
      },
    );
  }

  Future<void> sendInvitation(String recipientId, String gameType) async {
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

      print("VVVV: " + recipientId);

      // Wait for the room to become available
      String? roomId = await listenForInvitationRoomUpdate(recipientId);
      invitationRoomUpdateListener.cancel;
      rejectInvitation(recipientId);

      if (roomId != null) {
        print('Room available! roomId: $roomId');
        // Join the room using the roomId
        Room? room = await RoomService().getRoomById(roomId);
        await RoomService().joinRoom(roomId, playerName!);

        if (gameType == "User Input") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WordScreen(
                room: room!,
                playerName: playerName!,
                playerType: 1,
              ),
            ),
          );
        } else {
          String randomWord =
              UserService().generateRandomWord(room!.wordLength).toUpperCase();
          print('Random word of length ${room.wordLength}: ${randomWord}');

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => GameScreen(
                room: room,
                word: randomWord,
                playerName: playerName!,
                playerType: 1,
              ),
            ),
          );
        }
      } else {
        print('Room not available.');
      }

      print("End of listen");
    } catch (error) {
      print('Error sending invitation:');
    }
  }

  Future<List<Map<String, String>>> _fetchPlayers(
      List<String> roomSettings) async {
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
            List<String>? userRoomSettings =
                value['roomSettings']?.cast<String>();

            // Check if the player has the same roomSettings and roomSettings exist
            if (playerName != null &&
                playerStatus != null &&
                playerId != null &&
                userRoomSettings != null &&
                _isSameRoomSettings(roomSettings, userRoomSettings)) {
              players.add(
                  {'name': playerName, 'status': playerStatus, 'id': playerId});
            }
          });

          // Sort players alphabetically by name
          players.sort((a, b) => a['name']!.compareTo(b['name']!));
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

// Helper function to check if two lists have the same elements
  bool _isSameRoomSettings(
      List<String> roomSettings1, List<String> roomSettings2) {
    // Sort both lists and compare them
    roomSettings1.sort();
    roomSettings2.sort();
    return roomSettings1.toString() == roomSettings2.toString();
  }

  Future<bool?> showInvitationDialogWithTimeout(
      String invitationId, Duration timeout) async {
    Completer<bool?> completer =
        Completer(); // Use a completer for timeout handling

    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent dismissal by tapping outside the dialog
      builder: (context) => WillPopScope(
        // Prevent accidental dismissal by back button during timer
        onWillPop: () => Future.value(false), // Always return false
        child: AlertDialog(
          title: Text('Invitation'),
          content: Text('Do you want to accept this invitation?'),
          actions: [
            TextButton(
              onPressed: () {
                completer.complete(true); // Complete with true for accept
                Navigator.pop(context);
              },
              child: Text('Accept'),
            ),
            TextButton(
              onPressed: () {
                completer.complete(false); // Complete with false for reject
                Navigator.pop(context);
              },
              child: Text('Reject'),
            ),
          ],
        ),
      ),
    );

    // Start a timer to handle automatic rejection after timeout
    Timer timer = Timer.periodic(Duration(seconds: 1), (t) {
      int remainingSeconds =
          timeout.inSeconds - t.tick; // Calculate remaining seconds

      // Print the remaining seconds to the console
      print('Time remaining: $remainingSeconds seconds');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Time remaining: $remainingSeconds seconds'),
          duration: const Duration(milliseconds: 100),
        ),
      );

      if (!completer.isCompleted && remainingSeconds <= 0) {
        completer.complete(false); // Complete with false for automatic reject
        Navigator.pop(context);
        t.cancel(); // Cancel timer on completion or timeout
      }
    });

    // Wait for user response or timeout
    bool? result = await completer.future;
    timer.cancel(); // Cancel timer after getting a response

    return result;
  }

  Future<void> rejectInvitation(String invitationId) async {
    try {
      // Get a reference to the specific invitation
      final invitationRef = _invitationsRef.child(invitationId);

      // Delete the invitation at the given ID
      await invitationRef.remove();
    } catch (error) {
      print('Error rejecting invitation: $error');
    }
  }

  Future<void> acceptInvitation(
      String senderId, String userId, String type, String wordLength) async {
    try {
      // Get a reference to the specific invitation
      Room? xroom = await RoomService().findAvailableRoom(type, wordLength);
      if (xroom != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Room Found'),
          ),
        );
        /*
        int assign = await RoomService().joinRoom(roomKey, playerName!);

        if (assign == 0)
          print("Joined as player1");
        else if (assign == 1)
          print("Joined as player2");
        else
          print("Join failed");
          */

        await setOrUpdateInvitationRoomId(senderId, xroom.key);

        // Join the room after the other user joins after (2 seconds)
        Future.delayed(Duration(seconds: 2), () async {
          await RoomService().joinRoom(xroom.key, playerName!);
        });

        if (type == "User Input") {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WordScreen(
                  room: xroom!,
                  playerName: playerName!,
                  playerType: 2,
                ),
              ));
        } else {
          String randomWord =
              UserService().generateRandomWord(xroom.wordLength).toUpperCase();
          print('Random word of length ${xroom.wordLength}: ${randomWord}');

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => GameScreen(
                room: xroom,
                word: randomWord,
                playerName: playerName!,
                playerType: 2,
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Room not found'),
          ),
        );
      }
      // Show a snackbar to indicate that the invitation was rejected
    } catch (error) {
      print('Error accepting invitation: $error');
    }
  }

  Future<void> setOrUpdateInvitationRoomId(
      String invitationId, String roomId) async {
    DatabaseReference invitationRef = FirebaseDatabase.instance
        .ref()
        .child('invitations')
        .child(invitationId);

    try {
      await invitationRef.update({'roomId': roomId});
      print('Successfully set roomId for invitation: $invitationId');
    } catch (error) {
      print('Error setting roomId for invitation: $error');
      // Handle error accordingly (e.g., retry or notify user)
    }
  }

  late StreamSubscription<DatabaseEvent> invitationRoomUpdateListener;
  Future<String?> listenForInvitationRoomUpdate(String invitationId) async {
    Completer<String?> completer = Completer<String?>();

    DatabaseReference invitationRef = FirebaseDatabase.instance
        .ref()
        .child('invitations')
        .child(invitationId);

    invitationRoomUpdateListener = invitationRef.onValue.listen((event) {
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.exists) {
        Map<dynamic, dynamic>? invitationData = snapshot.value as Map?;
        if (invitationData!.containsKey('roomId')) {
          String roomId = invitationData['roomId'];
          completer.complete(roomId); // Resolve the completer with roomId
          // You might want to unsubscribe from the listener here
          // to avoid unnecessary listening after the room is available.
        }
      }
    });

    return completer.future;
  }
}
