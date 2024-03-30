import 'package:flutter/material.dart';
import 'package:wordle/screen/authentication/authenticate.dart';
import 'package:wordle/screen/home/home.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Return either Home or Authenticate widget
    return Authenticate();
  }
}
