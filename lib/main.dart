import 'package:flutter/material.dart';
import 'package:wordle/screen/game_screen.dart';
import 'package:wordle/screen/name_entry.dart';
import 'package:wordle/screen/room_maker.dart';
import 'package:wordle/screen/rooms_browser.dart';
import 'package:wordle/screen/word_entry.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: EnterNameScreen(),
      // routes: {
      //   '/room_maker': (context) => const RoomMaker("null"),
      // },
    );
  }
}
