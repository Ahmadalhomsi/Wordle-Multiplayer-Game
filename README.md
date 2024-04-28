# Wordle Game

## Description

This is a Flutter application for playing the Wordle game, where players try to guess a secret word within a limited number of attempts. The game supports both single-player and multiplayer modes.

## Features

- Single-player mode: Guess the word within a limited number of attempts.
- Multiplayer mode: Play against another player and compete to guess the word first.
- Real-time updates: See the opponent's guesses in real-time.
- Timer: A timer limits the time for each player's turn.
- Score calculation: Scores are calculated based on the accuracy and speed of guessing the word.

## Technologies Used

- Flutter for the front-end development.
- Firebase for real-time database and authentication.

## Installation

1. Clone this repository to your local machine.
2. Set up Firebase for your project and replace the Firebase configuration in `firebase_options.dart` with your own.
3. Run `flutter pub get` to install dependencies.
4. Run the app on an emulator or physical device using `flutter run`.

## Usage

- Launch the app and sign in or create an account.
- Choose between single-player and multiplayer mode.
- In single-player mode, try to guess the secret word within the given number of attempts.
- In multiplayer mode, compete with another player to guess the word first.
- Use the provided keyboard to enter your guesses.
- See real-time updates of the opponent's guesses.
- Earn scores based on the accuracy and speed of guessing.

## Firebase Configuration

To use Firebase services in this app, you'll need to set up a Firebase project and replace the configuration variables in `firebase_options.dart` with your own. Here's how the variables look like:

```dart
class DefaultFirebaseOptions {
  static const FirebaseOptions currentPlatform = FirebaseOptions(
    appId: 'your_app_id',
    apiKey: 'your_api_key',
    messagingSenderId: 'your_messaging_sender_id',
    projectId: 'your_project_id',
    databaseURL: 'your_database_url',
    storageBucket: 'your_storage_bucket',
    authDomain: 'your_auth_domain',
    measurementId: 'your_measurement_id',
  );
}

