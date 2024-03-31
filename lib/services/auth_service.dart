import 'package:firebase_auth/firebase_auth.dart';
import 'package:wordle/models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  FirebaseAuth getXAuth() {
    return _auth;
  }

// create user obj based on FirebaseUser
  UserX? _userFromFirebaseUser(User user) {
    // convert the firebase user to UserX
    return user != null ? UserX(uid: user.uid) : null;
  }

  // auth change user stream (similar to useEffect)
  Stream<UserX?> get userZ {
    return _auth
        .authStateChanges()
        .map((User? user) => _userFromFirebaseUser(user!));
  }

  Future signInAnon() async {
    try {
      final result = await FirebaseAuth.instance.signInAnonymously();
      final user = result.user;
      return _userFromFirebaseUser(user!); // it was user
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

// Sign in with email and password
  Future<User?> signInWithEmailAndPasswordX(
      String email, String password) async {
    try {
      print('Attempting to sign in with email and password...');

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('Error signing in with email and password: $e');
      return null;
    }
  }

  // Sign up with email and password
  Future<User?> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('Error signing up with email and password: $e');
      return null;
    }
  }

// Sign out
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

/*
  // Sign up with email and password
  Future<String?> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // Return null if sign up is successful
    } catch (e) {
      return e.toString(); // Return error message if sign up fails
    }
  }

  // Sign in with email and password
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // Return null if sign in is successful
    } catch (e) {
      return e.toString(); // Return error message if sign in fails
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
  */
}
