import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class Room {
  final String key;
  final String name;
  final String type;
  final bool isFull;
  final int wordLength;
  final String? player1;
  final String? player2;
  String? player1Word;
  String? player2Word;

  Room({
    required this.key,
    required this.name,
    required this.type,
    required this.isFull,
    required this.wordLength,
    this.player1,
    this.player2,
    this.player1Word,
    this.player2Word,
  });

  // Method to update player's word
  void updatePlayerWord(String word, int player) {
    // Update the word in Firebase Realtime Database
    DatabaseReference roomRef =
        FirebaseDatabase.instance.ref().child('rooms').child(key);

    if (player == 1) {
      // Player 1's word
      roomRef.update({
        'player1Word': word,
      });
    } else {
      // Player 2's word
      roomRef.update({
        'player2Word': word,
      });
    }
  }

  // Method to get player's word
  String getPlayerWord(String player) {
    if (player == player1 && player1Word != null) {
      return player1Word!;
    } else if (player == player2 && player2Word != null) {
      return player2Word!;
    } else {
      return ''; // Return empty string if player or word is not available
    }
  }

  Future<String> listenForPlayerWordChanges(String playerName) async {
    Completer<String> completer = Completer<String>();
    var roomRef =
        FirebaseDatabase.instance.ref('rooms/${key}/${playerName}Word');
    print("Listenning .........++" + key);

    roomRef.onValue.listen(
      (event) {
        final data = event.snapshot.value;
        print("DATAAAA:" + data.toString());

        if (data != null && data != '') {
          completer.complete(data.toString());
        }
      },
    );

    return completer.future;
  }

  Future<void> removePlayerFromRoom(String playerName) async {
    try {
      final roomRef = FirebaseDatabase.instance.ref('rooms/$key');
      final snapshot = await roomRef.get();

      if (snapshot.exists) {
        final roomData = snapshot.value as Map<dynamic, dynamic>;
        if (roomData['player1'] == playerName) {
          await roomRef.update({'player1': null});
        } else if (roomData['player2'] == playerName) {
          await roomRef.update({'player2': null});
        }
      } else {
        print('Room $key does not exist');
      }
    } catch (error) {
      print('Error removing player from room: $error');
    }
  }

  Room roomFromJson(Map<String, dynamic> json, String key) {
    print('key:' + key);
    return Room(
      key: key,
      isFull: json['isFull'] ?? false,
      name: json['name'] ?? '',
      player1: json['player1'] ?? '',
      type: json['type'] ?? '',
      wordLength: json['wordLength'] ?? 0,
      player2: json['player2'] ?? '',
    );
  }

  @override
  String toString() {
    return 'Room(key: $key, name: $name, type: $type, isFull: $isFull, wordLength: $wordLength)';
  }

  // Convert Room object to a Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'isFull': isFull,
      'wordLength': wordLength,
      'player1': player1,
      'player2': player2,
    };
  }

  factory Room.fromMap(Map<dynamic, dynamic> map, String key) {
    return Room(
      key: key,
      name: map['name'],
      type: map['type'],
      isFull: map['isFull'],
      wordLength: map['wordLength'],
    );
  }
}
