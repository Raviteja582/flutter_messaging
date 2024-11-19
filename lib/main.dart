import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'home-page.dart';
import 'login.dart';
import 'message-screen.dart';
import 'profile.dart';
import 'settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Application',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/', // Set the initial route
      routes: {
        '/': (context) => const SplashScreen(), // Splash Screen as the entry point
        '/home': (context) => HomePage(), // Home Page
        '/profile': (context) => const ProfilePage(), // Profile Page
        '/settings': (context) => const SettingsPage(), // Settings Page
        '/login': (context) => const LoginPage(), // Login Page
      },
    );
  }
}
