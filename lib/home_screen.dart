import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:badges/badges.dart' as badges;
import 'notificationsScreen.dart';
import 'ProfileScreen.dart';
import 'job_detail_screen.dart';
import 'loginscreen.dart';
import 'active_jobsscreen.dart'; // 📌 Bu satırı ekle

class HomeScreen extends StatefulWidget {
  final int userId;
  const HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List jobs = [];
  bool isLoading = true;
  int unreadCount = 0; // 🔴 Bildirim sayacı

  @override
  void initState() {
    super.initState();
    fetchJobs();
    checkUnreadApplications();
  }

  Future<void> fetchJobs() async {
    final url = Uri.parse('http://127.0.0.1:8000/jobs/');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          jobs = json.decode(response.body);
          isLoading = false;
        });
      } else {
        debugPrint('Sunucu hatası: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Bağlantı hatası: $e');
    }
  }

  Future<void> checkUnreadApplications() async {
    final url = Uri.parse(
        'http://127.0.0.1:8000/employer/${widget.userId}/unread_applications');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final unreadList = json.decode(response.body);
        setState(() {
          unreadCount = unreadList.length;
        });

        if (unreadList.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Yeni başvurularınız var!")),
          );
        }
      }
    } catch (e) {
      debugPrint('Bildirim kontrol hatası: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF2F5),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 103, 144, 153),
        title: const Text('Ana Sayfa'),
        actions: [
          badges.Badge(
            showBadge: unreadCount > 0,
            position: badges.BadgePosition.topEnd(top: -4, end: -4),
            badgeContent: Text(
              unreadCount.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            badgeStyle: const badges.BadgeStyle(
              badgeColor: Colors.red,
              padding: EdgeInsets.all(6),
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NotificationsScreen(userId: widget.userId),
                  ),
                );
                checkUnreadApplications(); // döndükten sonra tekrar kontrol edebilir
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text("Kullanıcı Adı"),
              accountEmail: Text("email@example.com"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40),
              ),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 103, 144, 153),
              ),
            ),
            _buildDrawerItem(Icons.home, 'Ana Sayfa', () {
              Navigator.pop(context);
            }),
            _buildDrawerItem(Icons.person, 'Profilim', () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()));
            }),
            _buildDrawerItem(Icons.work, 'İlan Ver', () {
              Navigator.pushNamed(context, '/post-job');
            }),
            _buildDrawerItem(Icons.list_alt, 'Aktif İlanlarım', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MyActiveJobsScreen(employerId: widget.userId),
                ),
              );
            }),
            _buildDrawerItem(Icons.logout, 'Çıkış Yap', () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()));
            }),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : jobs.isEmpty
              ? const Center(child: Text("Hiç ilan yok."))
              : Padding(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: jobs.length,
                    itemBuilder: (context, index) {
                      final job = jobs[index];
                      return _buildJobCard(context, job);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/post-job'),
        icon: const Icon(Icons.add),
        label: const Text('İlan Ver'),
        backgroundColor: const Color.fromARGB(255, 103, 144, 153),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  Widget _buildJobCard(BuildContext context, dynamic job) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          job['title'] ?? 'Başlık',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            job['description'] ?? 'Açıklama',
            style: const TextStyle(fontSize: 15),
          ),
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("₺${job['salary']?.toStringAsFixed(0) ?? '0'}",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const JobDetailScreen(),
                    settings: RouteSettings(arguments: {
                      'jobId': job['id'],
                    }),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromARGB(255, 103, 144, 153),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: const Size(80, 30),
              ),
              child: const Text(
                'Detaylar',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
