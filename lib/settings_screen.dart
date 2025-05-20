import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'profile_edit_screen.dart'; // Profil düzenleme ekranını import edin
import 'help_screen.dart';
import 'about_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isNotificationsEnabled = true;

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              const ProfileEditScreen()), // Profil düzenlemeye yönlendir
    );
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
