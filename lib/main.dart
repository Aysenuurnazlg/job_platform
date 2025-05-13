import 'package:flutter/material.dart';
import 'dart:io';

// Ekranlar
import 'ProfileScreen.dart';
import 'job_detail_screen.dart';
import 'loginscreen.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import 'NotificationsScreen.dart';
import 'settings_screen.dart';
import 'postJob_screen.dart';
import 'profile_edit_screen.dart';
import 'application.success.dart';

// CORS hatalarını önlemek için HTTP istemcisi
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
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
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/post-job': (context) => const PostJobScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/profile-edit': (context) => const ProfileEditScreen(),
        '/job-detail': (context) => const JobDetailScreen(),
        '/success': (context) =>
            const ApplicationSuccessScreen(applicationId: 12),
      },

      // ⬇️ Dinamik route'lar
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final userId = settings.arguments as int?;
          if (userId == null) {
            return MaterialPageRoute(
              builder: (context) => const Scaffold(
                body: Center(child: Text("HATA: Kullanıcı ID alınamadı.")),
              ),
            );
          }

          return MaterialPageRoute(
            builder: (context) => HomeScreen(userId: userId),
          );
        }

        if (settings.name == '/notifications') {
          final userId = settings.arguments as int?;
          if (userId == null) {
            return MaterialPageRoute(
              builder: (context) => const Scaffold(
                body: Center(
                    child: Text("HATA: Bildirim için kullanıcı ID alınamadı.")),
              ),
            );
          }

          return MaterialPageRoute(
            builder: (context) => NotificationsScreen(userId: userId),
          );
        }

        return null; // bilinmeyen route
      },
    );
  }
}
