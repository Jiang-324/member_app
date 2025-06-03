import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PhoneAuthScreen extends StatefulWidget {
  @override
  _PhoneAuthScreenState createState() => _PhoneAuthScreenState();

}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  String? verificationId;
  bool codeSent = false;
  bool isLoading = false;

  Future<void> verifyPhone() async {
    setState(() => isLoading = true);
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _phoneController.text,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          goToNextScreen();
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Verification failed: ${e.message}")),
          );
        },
        codeSent: (String verId, int? resendToken) {
          setState(() {
            verificationId = verId;
            codeSent = true;
            isLoading = false;
          });
        },
        codeAutoRetrievalTimeout: (String verId) {
          verificationId = verId;
        },
    );
  }
  Future<void> signInWithOTP() async {
    final credential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: _otpController.text.trim(),
    );
    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      goToNextScreen();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid Code")),
      );
    }
  }
  void goToNextScreen() {
    Navigator.pushReplacementNamed(context, '/membershipForm');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Phone Verification')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
        ? Center(child: CircularProgressIndicator())
        : Column(
          children: [
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number (+123456879)',
              ),
              keyboardType: TextInputType.phone,
            ),
            if(codeSent)
              TextField(
                controller: _otpController,
                decoration: InputDecoration(labelText: 'Enter OTP'),
                keyboardType: TextInputType.number,
              ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: codeSent ? signInWithOTP : verifyPhone,
                child: Text(codeSent ? 'Verify OTP' : 'Send OTP'),
            ),
          ],
        ),
      ),
    );
    // TODO: implement build
    throw UnimplementedError();
  }

}