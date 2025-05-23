import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Ekranlar
import 'ProfileScreen.dart';
import 'job_detail_screen.dart';
import 'loginscreen.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import 'notificationsScreen.dart';
import 'settings_screen.dart';
import 'postJob_screen.dart';
import 'profile_edit_screen.dart';

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
        primaryColor: const Color(0xFF679099),
        scaffoldBackgroundColor: const Color(0xFFEFF2F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF679099),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF679099),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        fontFamily: 'Arial',
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/settings': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is int) {
            return SettingsScreen(userId: args);
          }
          return const LoginScreen(); // Eğer userId yoksa login ekranına yönlendir
        },
        '/profile': (context) => const ProfileScreen(
            userId: 1, isOwnProfile: true), // örnek değerler
        '/': (context) => const RegisterScreen(),
        '/profileEdit': (context) => const ProfileEditScreen(),
        '/job-detail': (context) => const JobDetailScreen(),
      },
      onGenerateRoute: (settings) {
        // Hata sayfası widget'ı
        Widget errorPage(String message) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Hata'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Geri Dön'),
                  ),
                ],
              ),
            ),
          );
        }

        // Route işleyicileri
        switch (settings.name) {
          case '/home':
            final userId = settings.arguments as int?;
            if (userId == null) {
              return MaterialPageRoute(
                builder: (context) => errorPage(
                    'Kullanıcı ID alınamadı. Lütfen tekrar giriş yapın.'),
              );
            }
            return MaterialPageRoute(
              builder: (context) => HomeScreen(userId: userId),
            );

          case '/notifications':
            final userId = settings.arguments as int?;
            if (userId == null) {
              return MaterialPageRoute(
                builder: (context) =>
                    errorPage('Bildirimler için kullanıcı ID alınamadı.'),
              );
            }
            return MaterialPageRoute(
              builder: (context) => NotificationsScreen(userId: userId),
            );

          case '/post-job':
            final userId = settings.arguments as int?;
            if (userId == null) {
              return MaterialPageRoute(
                builder: (context) =>
                    errorPage('İlan vermek için kullanıcı ID alınamadı.'),
              );
            }
            return MaterialPageRoute(
              builder: (context) => PostJobScreen(userId: userId),
            );

          case '/job-detail':
            return MaterialPageRoute(
              builder: (context) => const JobDetailScreen(),
            );

          default:
            return MaterialPageRoute(
              builder: (context) => errorPage('Sayfa bulunamadı.'),
            );
        }
      },
    );
  }
}
