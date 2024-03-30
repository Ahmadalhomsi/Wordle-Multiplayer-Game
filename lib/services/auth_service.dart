import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  Future signInAnon() async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      final result = await auth.signInAnonymously();
      final user = result.user;
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
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
