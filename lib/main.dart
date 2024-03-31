import 'package:firebase_core/firebase_core.dart';
import 'package:wordle/screen/rooms_browser.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:wordle/screen/wrapper.dart';

void main() {
  // Run the Firebase initialization asynchronously
  initializeFirebaseAndRunApp();
}

Future<void> initializeFirebaseAndRunApp() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure Flutter binding is initialized
  print("-----------+++");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Initialize Firebase asynchronously
  print("-----------+++");
  runApp(
      const MyApp()); // Run the app after Firebase initialization is complete
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
      home: Wrapper(), //  EnterNameScreen()
      // routes: {
      //   '/room_maker': (context) => const RoomMaker("null"),
      // },
    );
  }
}
