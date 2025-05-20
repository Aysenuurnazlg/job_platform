import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'profile_edit_screen.dart'; // Profil düzenleme ekranını import edin
import 'help_screen.dart';
import 'about_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SettingsScreen extends StatefulWidget {
  final int userId;

  const SettingsScreen({
    super.key,
    required this.userId,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isNotificationsEnabled = true;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      print('Token: $token');

      // API'den kullanıcı bilgilerini al
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/users/me'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('API Yanıt Kodu: ${response.statusCode}');
      print('API Yanıtı: ${response.body}');

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        setState(() {
          _userData = {
            'id': widget.userId,
            'full_name': userData['full_name'],
            'email': userData['email'],
            'phone_number': userData['phone_number'],
            'bio': userData['bio'],
          };
        });
        print('Yüklenen kullanıcı verileri: $_userData');
      } else {
        print('API Hatası: ${response.statusCode}');
      }
    } catch (e) {
      print('Veri yükleme hatası: $e');
    }
  }

  void _navigateToProfile() {
    if (_userData != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfileEditScreen(),
          settings: RouteSettings(arguments: _userData),
        ),
      ).then((_) => _loadUserData()); // Profil güncellendiğinde verileri yenile
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kullanıcı bilgileri yüklenemedi'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToLanguageSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dil Seçimi'),
        content: const Text('Burada dil değiştirme seçenekleri olacak.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _toggleNotifications(bool value) {
    setState(() {
      isNotificationsEnabled = value;
    });
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Oturumunuzu kapatmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Alert kapat
              SystemNavigator.pop(); // Uygulamayı kapat
            },
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }

  void _navigateToHelp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HelpScreen()),
    );
  }

  void _navigateToAbout() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AboutScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Profil düzenleme card
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profil Düzenle'),
                subtitle:
                    const Text('Bilgilerinizi görüntüleyin veya değiştirin'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _navigateToProfile, // Profil düzenlemeye yönlendir
              ),
            ),
            const SizedBox(height: 12),

            // Notification toggle
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: SwitchListTile(
                secondary: const Icon(Icons.notifications),
                title: const Text('Bildirimler'),
                value: isNotificationsEnabled,
                onChanged: _toggleNotifications,
              ),
            ),
            const SizedBox(height: 12),

            // Help and Support
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.help),
                title: const Text('Yardım ve Destek'),
                onTap: _navigateToHelp,
              ),
            ),
            const SizedBox(height: 12),

            // About
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.info),
                title: const Text('Hakkında'),
                onTap: _navigateToAbout,
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title:
                  const Text('Çıkış Yap', style: TextStyle(color: Colors.red)),
              onTap: () => _confirmLogout(context),
            ),
          ],
        ),
      ),
    );
  }
}
