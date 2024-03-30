import 'package:flutter/material.dart';
import 'package:wordle/screen/authentication/sign_in.dart';
import 'package:wordle/services/auth_service.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({super.key});

  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SignIn(), // Text("Authenticate")
    );
  }
}
