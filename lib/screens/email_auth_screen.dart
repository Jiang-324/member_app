import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmailAuthScreen extends StatefulWidget {
  @override
  _EmailAuthScreenState createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends State<EmailAuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLogin = true;
  bool _isLoading = false;

  Future<void> saveUserToFirestore(User user) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    final userData = {
      'uid': user.uid,
      'email': user.email,
      'phone': user.phoneNumber,
      'createdAt': FieldValue.serverTimestamp()
    };
    await docRef.set(userData, SetOptions(merge: true));
  }

  Future<void> handleAuth() async {
    try {
      UserCredential userCredential;
      User? user;
      setState(() => _isLoading = true);
      if(isLogin) {
        userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
        );
        user = userCredential.user;
        if(user != null) {
          await saveUserToFirestore(user);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Login Successful")),
          );
        }
      } else {
        userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
        );
        user = userCredential.user;
        if( user != null) {
          await saveUserToFirestore(user);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Registration successful")),
          );
        }
      }
      if( user != null ){
        Navigator.pushReplacementNamed(context, '/homepage');
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Authentication Failed')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'Login with Email' : 'Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                onPressed: handleAuth,
                child: Text(isLogin ? 'Login' : 'Register'),
            ),
            TextButton(
                onPressed: () => setState(() => isLogin = !isLogin),
                child: Text(isLogin
                  ? "Don't have an account? Register"
                  : "Already registered? Login"))
          ],
        ),
      ),
    );
  }
}