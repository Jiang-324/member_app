import 'package:flutter/material.dart';

class ChoiceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Choose Login Method')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/phoneAuth'),
                child: Text('Login with Phone (SMS)'),
            ),
            ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/emailAuth'),
                child: Text('Login with Email'),
            ),
          ],
        ),
      ),
    );
  }

}