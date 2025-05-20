import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MyApplicationsScreen extends StatefulWidget {
  final int userId;
  const MyApplicationsScreen({super.key, required this.userId});

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> appliedJobs = [];
  List<dynamic> acceptedJobs = [];
  List<dynamic> completedJobs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchApplications();
  }

  Future<void> fetchApplications() async {
    final url = Uri.parse(
        'http://127.0.0.1:8000/user/${widget.userId}/applications'); // Backend'e göre düzenle
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          appliedJobs = data['applied'] ?? [];
          acceptedJobs = data['accepted'] ?? [];
          completedJobs = data['completed'] ?? [];
          isLoading = false;
        });
      } else {
        debugPrint('Sunucu hatası: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Bağlantı hatası: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildJobList(List<dynamic> jobs, String emptyMessage) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (jobs.isEmpty) {
      return Center(child: Text(emptyMessage));
    } else {
      return ListView.builder(
        itemCount: jobs.length,
        itemBuilder: (context, index) {
          final job = jobs[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(job['title'] ?? 'İş Başlığı'),
              subtitle: Text(job['description'] ?? 'Açıklama'),
              trailing: Text("₺${job['salary']?.toStringAsFixed(0) ?? '0'}"),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          indicatorColor: const Color.fromARGB(255, 103, 144, 153),
          tabs: const [
            Tab(text: 'Başvurulan'),
            Tab(text: 'Kabul Edilen'),
            Tab(text: 'Tamamlanan'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildJobList(appliedJobs, "Başvurduğunuz iş yok."),
              _buildJobList(acceptedJobs, "Henüz kabul edilen iş yok."),
              _buildJobList(completedJobs, "Tamamlanan iş yok."),
            ],
          ),
        ),
      ],
    );
  }
}
