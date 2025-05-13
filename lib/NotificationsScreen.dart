import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationsScreen extends StatefulWidget {
  final int userId;

  const NotificationsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List notifications = [];

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    final url =
        Uri.parse("http://127.0.0.1:8000/users/${widget.userId}/notifications");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        notifications = json.decode(response.body);
      });
    } else {
      debugPrint("Bildirimler alınamadı: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bildirimler')),
      body: notifications.isEmpty
          ? const Center(child: Text("Henüz bildirim yok."))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final item = notifications[index];
                return ListTile(
                  leading: const Icon(Icons.notifications),
                  title: Text("Başvurduğunuz ilan (ID: ${item['job_id']})"),
                  subtitle: Text("Tarih: ${item['applicationDate']}"),
                );
              },
            ),
    );
  }
}
