import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:badges/badges.dart' as badges;
import 'notificationsScreen.dart';
import 'ProfileScreen.dart';
import 'job_detail_screen.dart';
import 'loginscreen.dart';
import 'active_jobsscreen.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final int userId;

  const HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> jobs = [];
  bool isLoading = true;
  int _unreadNotifications = 0;
  int _prevUnreadCount = 0;
  Timer? _notificationTimer;

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') ?? '';
  }

  Future<Map<String, dynamic>> fetchProfileData(int id) async {
    try {
      final token = await getToken();
      final url = 'http://127.0.0.1:8000/users/me';

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
  void initState() {
    super.initState();
    fetchJobs();
    fetchUnreadNotifications();
    _notificationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      fetchUnreadNotifications();
    });
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchJobs() async {
    final url = Uri.parse('http://127.0.0.1:8000/jobs/');
    try {
      final response = await http.get(url);
      final utf8Body = utf8.decode(response.bodyBytes);
      final data = json.decode(utf8Body);

      if (response.statusCode == 200) {
        setState(() {
          jobs = data;
          isLoading = false;
        });
      } else {
        debugPrint('Sunucu hatası: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Bağlantı hatası: $e');
    }
  }

  Future<void> fetchUnreadNotifications() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://127.0.0.1:8000/employer/${widget.userId}/notifications'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> notifications = json.decode(response.body);
        final unreadCount = notifications.where((n) => !n['is_read']).length;

        if (mounted) {
          setState(() {
            _unreadNotifications = unreadCount;
          });

          if (unreadCount > _prevUnreadCount) {
            _showTopNotification(unreadCount);
          }

          _prevUnreadCount = unreadCount;
        }
      }
    } catch (e) {
      // Hata durumunda sessizce devam et
    }
  }

  void _showTopNotification(int count) {
    final overlay = Overlay.of(context);
    late final OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            offset: const Offset(0, 0),
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_active, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '$count yeni bildiriminiz var!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      overlayEntry.remove();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // 3 saniye sonra bildirimi kaldır
    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
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
            showBadge: _unreadNotifications > 0,
            badgeContent: Text(
              '$_unreadNotifications',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
            badgeStyle: badges.BadgeStyle(
              badgeColor: Colors.red,
              padding: const EdgeInsets.all(5),
              borderRadius: BorderRadius.circular(10),
            ),
            position: badges.BadgePosition.topEnd(top: 4, end: 4),
            child: IconButton(
              icon: const Icon(Icons.notifications, size: 28),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        NotificationsScreen(userId: widget.userId),
                  ),
                ).then((_) => fetchUnreadNotifications());
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingsScreen(userId: widget.userId),
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            FutureBuilder<Map<String, dynamic>>(
              future: fetchProfileData(widget.userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const UserAccountsDrawerHeader(
                    accountName: Text("Yükleniyor..."),
                    accountEmail: Text(""),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: CircularProgressIndicator(),
                    ),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 103, 144, 153),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return const UserAccountsDrawerHeader(
                    accountName: Text("Hata"),
                    accountEmail: Text("Bilgiler yüklenemedi"),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.error, size: 40),
                    ),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 103, 144, 153),
                    ),
                  );
                }

                final profileData = snapshot.data!;
                return UserAccountsDrawerHeader(
                  accountName:
                      Text(profileData['full_name'] ?? "İsimsiz Kullanıcı"),
                  accountEmail: Text(profileData['email'] ?? ""),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      (profileData['full_name'] ?? "?")
                          .substring(0, 1)
                          .toUpperCase(),
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 103, 144, 153),
                  ),
                );
              },
            ),
            _buildDrawerItem(Icons.home, 'Ana Sayfa', () {
              Navigator.pop(context);
            }),
            _buildDrawerItem(Icons.person, 'Profilim', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(
                    userId: widget.userId,
                    isOwnProfile: true,
                  ),
                ),
              );
            }),
            _buildDrawerItem(Icons.work, 'İlan Ver', () async {
              await Navigator.pushNamed(
                context,
                '/post-job',
                arguments: widget.userId,
              );
              fetchJobs();
            }),
            _buildDrawerItem(Icons.list_alt, 'İlanlarım', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MyActiveJobsScreen(employerId: widget.userId),
                ),
              );
            }),
            _buildDrawerItem(Icons.logout, 'Çıkış Yap', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
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
        onPressed: () async {
          await Navigator.pushNamed(
            context,
            '/post-job',
            arguments: widget.userId,
          );
          fetchJobs();
        },
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
            Text(
              "₺${job['salary']?.toStringAsFixed(0) ?? '0'}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
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
