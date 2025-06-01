import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'screens/membership_form_screen.dart';
import 'screens/news_feed_screen.dart';
import 'screens/qr_code_screen.dart';
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
        '/': (context) => const HomePage(),
        '/news': (context) => const NewsPage(),
        '/apply': (context) => const MembershipFormPage(),
        '/qrcode': (context) => const QRCodePage(),

      },

    );
    // TODO: implement build
    throw UnimplementedError();
  }

}