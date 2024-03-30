import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wordle/services/auth_service.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auths = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.brown[100],
        appBar: AppBar(
          backgroundColor: Colors.brown[400],
          elevation: 0.0,
          title: Text("Sign in Screen"),
        ),
        body: Container(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
          child: ElevatedButton(
            child: Text('Sign in anon'),
            onPressed: () async {
              dynamic result = await _auths.signInAnon();
              if (result == null)
                print('error sign in');
              else {
                print("signed in");
                print(result);
              }
            },
          ),
        ));
  }
}
