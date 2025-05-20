import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hakkında'),
        backgroundColor: const Color.fromARGB(255, 103, 144, 153),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color.fromARGB(255, 103, 144, 153),
              child: Icon(
                Icons.work,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Engelli ve Yaşlılara Yardımcı İş Platformu',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Versiyon 1.0.0',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Hakkımızda',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Bu platform, engelli ve yaşlı bireylerin iş bulma süreçlerini kolaylaştırmak ve işverenlerin uygun adayları bulmalarını sağlamak amacıyla geliştirilmiştir. Amacımız, herkesin eşit fırsatlara sahip olduğu bir iş piyasası oluşturmaktır.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            const Text(
              'Özellikler',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildFeatureItem(
              Icons.work,
              'İş İlanları',
              'Engelli ve yaşlı dostu iş ilanlarını görüntüleyin',
            ),
            _buildFeatureItem(
              Icons.person,
              'Profil Yönetimi',
              'Kişisel bilgilerinizi ve tercihlerinizi yönetin',
            ),
            _buildFeatureItem(
              Icons.notifications,
              'Bildirimler',
              'Yeni iş ilanları ve başvurular hakkında anında bilgi alın',
            ),
            const SizedBox(height: 32),
            const Text(
              '© 2024 Tüm hakları saklıdır.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color.fromARGB(255, 103, 144, 153)),
        title: Text(title),
        subtitle: Text(description),
      ),
    );
  }
}
