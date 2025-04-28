import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'ProfileScreen.dart';  // Profil ekranını import ettik
import 'NotificationsScreen.dart';  // Bildirim ekranı import
import 'settings_screen.dart';  // Ayar ekranı import
import 'postJob_screen.dart';  // İlan verme ekranı import
import 'jobDetail_screen.dart';  // İlan detay ekranı import
import 'loginscreen.dart';
import 'register_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Engelli ve Yaşlılara Yardımcı İş Platformu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        fontFamily: 'Arial',
      ),
      initialRoute: '/',
     // İlk açılacak sayfa
      home: const LoginScreen(),

      // Rotalar
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/post-job': (context) => const PostJobScreen(),
        '/job-detail': (context) => const JobDetailScreen(),
      },
    );
  }
}
