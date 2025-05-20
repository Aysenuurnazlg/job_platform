import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yardım ve Destek'),
        backgroundColor: const Color.fromARGB(255, 103, 144, 153),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sık Sorulan Sorular',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildFAQItem(
              'Nasıl iş ilanı verebilirim?',
              'Ana sayfadaki "İlan Ver" butonuna tıklayarak veya menüden "İlan Ver" seçeneğini kullanarak yeni bir iş ilanı oluşturabilirsiniz.',
            ),
            _buildFAQItem(
              'Başvurularımı nasıl takip edebilirim?',
              'Profil sayfanızdan "Başvurularım" bölümüne giderek tüm başvurularınızı görüntüleyebilir ve durumlarını takip edebilirsiniz.',
            ),
            _buildFAQItem(
              'Bildirimleri nasıl yönetebilirim?',
              'Ayarlar sayfasından bildirim tercihlerinizi değiştirebilirsiniz.',
            ),
            const SizedBox(height: 24),
            const Text(
              'İletişim',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildContactItem(
              Icons.email,
              'E-posta',
              'destek@isplatformu.com',
            ),
            _buildContactItem(
              Icons.phone,
              'Telefon',
              '+90 555 123 4567',
            ),
            _buildContactItem(
              Icons.location_on,
              'Adres',
              'İstanbul, Türkiye',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              answer,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String title, String content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color.fromARGB(255, 103, 144, 153)),
        title: Text(title),
        subtitle: Text(content),
      ),
    );
  }
}
