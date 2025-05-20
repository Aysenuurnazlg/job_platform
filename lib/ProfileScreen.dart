import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  final int? userId;
  final bool isOwnProfile;

  const ProfileScreen({
    super.key,
    this.userId,
    this.isOwnProfile = true,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _profileFuture;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() {
    setState(() {
      _profileFuture = fetchProfileData(widget.userId!);
    });
  }

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') ?? '';
  }

  Future<Map<String, dynamic>> fetchProfileData(int id) async {
    try {
      final token = await getToken();
      final url = widget.isOwnProfile
          ? 'http://127.0.0.1:8000/users/me'
          : 'http://127.0.0.1:8000/users/$id';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Kullanıcı bilgileri alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Profil bilgileri alınırken bir hata oluştu: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(widget.isOwnProfile ? 'Profilim' : 'Profil'),
        backgroundColor: const Color.fromARGB(255, 103, 144, 153),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (widget.isOwnProfile)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SettingsScreen(userId: widget.userId!),
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _loadProfileData();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
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
                    'Hata: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _loadProfileData();
                      });
                    },
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          final profileData = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const CircleAvatar(radius: 50),
                const SizedBox(height: 12),
                Text(
                  profileData['full_name'],
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  profileData['bio'] ?? '',
                  style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.black54),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _infoCard(
                      title: 'Aldığı İş',
                      value: '${profileData['completed_jobs'] ?? 0}',
                    ),
                    _infoCard(
                      title: 'Puan',
                      value: (profileData['rating'] ?? 0).toStringAsFixed(1),
                      icon: Icons.star,
                      iconColor: Colors.amber,
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                _sectionTitle('Aldığı İş Türleri'),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: (profileData['job_types'] ?? [])
                      .map<Widget>((type) => Chip(
                            label: Text(type),
                            backgroundColor: Colors.blueGrey.shade100,
                          ))
                      .toList(),
                ),
                const SizedBox(height: 30),
                _sectionTitle('Yorumlar'),
                ...((profileData['reviews'] ?? []) as List)
                    .map<Widget>((review) => Card(
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
                                        fontSize: 12,
                                        color: Colors.grey.shade600),
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
                if (widget.isOwnProfile)
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.pushNamed(
                        context,
                        '/profileEdit',
                        arguments: {
                          'id': widget.userId,
                          'full_name': profileData['full_name'],
                          'email': profileData['email'],
                          'phone_number': profileData['phone_number'],
                          'bio': profileData['bio'] ?? '',
                        },
                      );

                      if (result == true) {
                        _loadProfileData(); // veriyi yeniden yükle
                      }
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Profil Düzenle'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 35),
                      backgroundColor: const Color.fromARGB(255, 153, 199, 212),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoCard({
    required String title,
    required String value,
    IconData? icon,
    Color? iconColor,
  }) {
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
                      fontSize: 22, fontWeight: FontWeight.bold),
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
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
