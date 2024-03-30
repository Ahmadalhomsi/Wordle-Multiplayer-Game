import 'package:flutter/material.dart';
import 'package:wordle/screen/name_entry.dart';
import 'package:wordle/services/auth_service.dart';

class SignUp extends StatelessWidget {
  const SignUp({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.brown[100],
      appBar: AppBar(
        backgroundColor: Colors.brown[400],
        elevation: 0.0,
        title: const Text("Sign Up Screen"),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Column(
          children: [
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String email = emailController.text.trim();
                String password = passwordController.text.trim();
                dynamic result = await AuthService()
                    .signUpWithEmailAndPassword(email, password);
                if (result == null) {
                  print('Sign-up failed');
                } else {
                  print('Sign-up successful');
                  // Move the user to EnterNameScreen after successful sign-up
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => EnterNameScreen()),
                  );
                }
              },
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
