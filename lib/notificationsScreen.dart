import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'dart:async';

class NotificationsScreen extends StatefulWidget {
  final int userId;
  const NotificationsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> notifications = [];
  bool isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
    // Her 10 saniyede bir bildirimleri kontrol et
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchNotifications();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchNotifications() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://127.0.0.1:8000/employer/${widget.userId}/notifications'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> decodedNotifications = json.decode(response.body);

        // Okunmamış bildirimleri otomatik olarak okundu olarak işaretle
        for (var notification in decodedNotifications) {
          if (!notification['is_read']) {
            await markAsRead(notification['job_id']);
          }
        }

        setState(() {
          notifications = decodedNotifications;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> markAsRead(int jobId) async {
    try {
      await http.post(
        Uri.parse(
            'http://127.0.0.1:8000/employer/${widget.userId}/mark_notification_read/$jobId'),
      );
    } catch (e) {
      // Hata durumunda sessizce devam et
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler'),
        backgroundColor: const Color.fromARGB(255, 103, 144, 153),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              fetchNotifications();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Henüz bildiriminiz yok',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                          });
                          fetchNotifications();
                        },
                        child: const Text('Yenile'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchNotifications,
                  child: ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      final date =
                          DateTime.parse(notification['application_date']);
                      final formattedDate =
                          DateFormat('dd.MM.yyyy HH:mm').format(date);

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        elevation: 2,
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(
                            '${notification['applicant_name']} adlı kullanıcı başvurdu',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'İlan: ${notification['job_title']}',
                                style: const TextStyle(
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                'Tarih: $formattedDate',
                                style: const TextStyle(
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                'Telefon: ${notification['applicant_phone']}',
                                style: const TextStyle(
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
