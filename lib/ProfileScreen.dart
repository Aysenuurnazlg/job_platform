import 'package:flutter/material.dart';

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
        'comment': 'Çok hızlı ve yardımseverdi.'
      },
      {
        'name': 'Zeynep K.',
        'rating': 4,
        'comment': 'İyi iş çıkardı, teşekkür ederim.'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage('assets/profile_placeholder.png'), // profil resmi için varsayılan
            ),
            const SizedBox(height: 10),
            const Center(child: Text('Yaman Koper', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
            const SizedBox(height: 20),

            // Aldığı iş sayısı ve puanı
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Text('Aldığı İş', style: TextStyle(fontSize: 20)),
                    Text('$completedJobs', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  children: [
                    const Text('Puan', style: TextStyle(fontSize: 20)),
                    Row(
                      children: [
                        Text(rating.toString(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        Icon(Icons.star, color: Colors.amber[600]),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Aldığı iş türleri
            const Text('Aldığı İş Türleri', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children: jobTypes.map((type) => Chip(label: Text(type))).toList(),
            ),
            const SizedBox(height: 20),

            // Yorumlar
            const Text('Yorumlar', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...reviews.map((review) => Card(
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: ListTile(
                title: Text(review['name']),
                subtitle: Text(review['comment']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    review['rating'],
                    (index) => const Icon(Icons.star, size: 16, color: Colors.amber),
                  ),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
