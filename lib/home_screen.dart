import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ProfileScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List jobs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchJobs();
  }

  Future<void> fetchJobs() async {
    final url = Uri.parse('http://127.0.0.1:8000/jobs');

    // Android emulator için uygun
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          jobs = json.decode(response.body);
          isLoading = false;
        });
      } else {
        print('Sunucu hatası: ${response.statusCode}');
      }
    } catch (e) {
      print('Bağlantı hatası: $e');
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
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
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
            _buildDrawerItem(Icons.logout, 'Çıkış Yap', () {
              Navigator.pushReplacementNamed(context, '/');
            }),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : jobs.isEmpty
              ? const Center(child: Text("Hiç ilan yok."))
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 16, bottom: 80),
                  itemCount: jobs.length,
                  itemBuilder: (context, index) {
                    final job = jobs[index];
                    return _buildJobCard(context, job);
                  },
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        trailing: Text("₺${job['salary']?.toStringAsFixed(0) ?? '0'}"),
      ),
    );
  }
}
