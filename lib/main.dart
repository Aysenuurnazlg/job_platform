import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'ProfileScreen.dart';
import 'NotificationsScreen.dart';
import 'settings_screen.dart';
import 'postJob_screen.dart';
import 'job_detail_screen.dart';
import 'loginscreen.dart';
import 'register_screen.dart';
import 'profile_edit_screen.dart';

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

      // Uygulama giriş ekranıyla başlar
      initialRoute: '/login',

      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/post-job': (context) => const PostJobScreen(),
        '/job-detail': (context) => const JobDetailScreen(),

        // 🔁 ProfileEditScreen'e arguments ile veri göndereceğiz
        '/profile-edit': (context) => const ProfileEditScreen(),
      },
    );
  }
}
