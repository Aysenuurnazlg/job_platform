import 'package:flutter/material.dart';
import 'settings_screen.dart'; // Ayarlar ekranını import ettik.
import 'profile_edit_screen.dart'; // Profil düzenleme ekranını import ettik.

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Örnek veriler
    int completedJobs = 12;
    double rating = 4.5;
    List<String> jobTypes = ['Temizlik', 'Alışveriş', 'Teknik Destek'];
    List<Map<String, dynamic>> reviews = [
      {
        'name': 'Ali Y.',
        'rating': 5,
        'comment': 'Çok hızlı ve yardımseverdi.',
        'date': '12 Mart 2025'
      },
      {
        'name': 'Zeynep K.',
        'rating': 4,
        'comment': 'İyi iş çıkardı, teşekkür ederim.',
        'date': '8 Mart 2025'
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Profilim'),
        backgroundColor: const Color.fromARGB(255, 103, 144, 153),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Ayarlar ekranına yönlendiriyoruz
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              //backgroundImage: AssetImage('assets/profile_placeholder.png'),
            ),
            const SizedBox(height: 12),
            const Text(
              'Yaman Koper',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            const SizedBox(height: 12),
            const Text(
              'Yardımcı İşler İçin Hedeflerime Ulaşıyorum',
              style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.black54),
            ),
            const SizedBox(height: 24),

            // İş & Puan
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _infoCard(title: 'Aldığı İş', value: '$completedJobs'),
                _infoCard(
                    title: 'Puan',
                    value: rating.toStringAsFixed(1),
                    icon: Icons.star,
                    iconColor: Colors.amber),
              ],
            ),
            const SizedBox(height: 30),

            _sectionTitle('Aldığı İş Türleri'),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: jobTypes
                  .map((type) => Chip(
                        label: Text(type),
                        backgroundColor: Colors.blueGrey.shade100,
                      ))
                  .toList(),
            ),
            const SizedBox(height: 30),

            _sectionTitle('Yorumlar'),
            ...reviews.map((review) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: ListTile(
                    title: Text(review['name']),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(review['comment']),
                          const SizedBox(height: 4),
                          Text(
                            'Yorum Tarihi: ${review['date']}',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < review['rating']
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                )),
            const SizedBox(height: 30),

            // Profil Düzenleme Butonu
            ElevatedButton.icon(
              onPressed: () {
                // Profil düzenleme ekranına yönlendiriyoruz
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileEditScreen()),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text('Profil Düzenle'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 35),
                backgroundColor: const Color.fromARGB(255, 153, 199, 212),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(
      {required String title,
      required String value,
      IconData? icon,
      Color? iconColor}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 140,
        height: 90,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                if (icon != null) ...[
                  const SizedBox(width: 4),
                  Icon(icon, size: 20, color: iconColor),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
    );
  }
}
