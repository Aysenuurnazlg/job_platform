import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'ProfileScreen.dart'; // Profil ekranını import ettik
import 'NotificationsScreen.dart'; // Bildirim ekranı import
import 'settings_screen.dart'; // Ayar ekranı import
import 'postJob_screen.dart'; // İlan verme ekranı import
import 'jobDetail_screen.dart'; // İlan detay ekranı import
import 'loginscreen.dart';
import 'register_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

Future<void> registerUser(String name, String email, String password) async {
  final url = Uri.parse('http://10.0.2.2:8000/users/'); // Android emülatör için
  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "name": name,
      "email": email,
      "password": password,
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    print("Kayıt başarılı: ${response.body}");
  } else {
    print("Hata: ${response.statusCode} ${response.body}");
  }
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
