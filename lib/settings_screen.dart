import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: ListView(
        children: [
          const ListTile(
            leading: Icon(Icons.person),
            title: Text('Profil'),
            subtitle: Text('Bilgileri görüntüle veya değiştir'),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Karanlık Tema'),
            value: false,
            onChanged: (bool value) {
              // Temayı değiştir
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Çıkış Yap'),
            onTap: () {
              // Çıkış yapma işlemleri
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
