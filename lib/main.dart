import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:member/screens/email_auth_screen.dart';
import 'package:member/screens/phone_auth_screen.dart';
import 'screens/edit_profile_page.dart';
import 'screens/application_submitted_screen.dart';
import 'screens/home_page.dart';
import 'screens/membership_form_screen.dart';
import 'screens/news_feed_screen.dart';
import 'screens/qr_code_screen.dart';
import 'screens/choiceScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling background messages: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MemberApp());
}

class MemberApp extends StatelessWidget {
  const MemberApp({ super.key });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Member App',
      theme: ThemeData(
        primarySwatch: Colors.blue
      ),
      initialRoute: '/',
      routes: {
        // '/': (context) => ChoiceScreen(),
        '/phoneAuth': (context) => PhoneAuthScreen(),
        '/emailAuth': (context) => EmailAuthScreen(),
        '/news': (context) => const NewsPage(),
        '/homepage': (context) => const HomePage(),
        '/membershipForm': (context) => const MembershipFormPage(),
        '/qrcode': (context) => const QRCodePage(),
        '/applicationSubmitted': (context) => const ApplicationSubmittedScreen(),
        '/editProfile': (context) => const EditProfilePage(),

      },
      home: ChoiceScreen(),

    );
  }
}