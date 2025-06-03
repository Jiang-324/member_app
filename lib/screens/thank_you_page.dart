import 'package:flutter/material.dart';

class ThankYouPage extends StatelessWidget {
  final String name;
  final String email;
  final String phone;

  const ThankYouPage({
   super.key,
   required this.name,
   required this.email,
   required this.phone
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thank You')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🎉 Your application has been submitted!', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 24),
            Text('👤 Name: $name', style: TextStyle(fontSize: 16)),
            Text('📧 Email: $email', style: TextStyle(fontSize: 16)),
            Text('📱 Phone: $phone', style: TextStyle(fontSize: 16)),
            const Spacer(),
            Center(
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(context, ModalRoute.withName('/homepage'));
                  },
                  child: const Text('Back to Home'),
              ),
            )

          ],
        ),
      ),
    );
  }
}