import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class RateWorkerScreen extends StatefulWidget {
  final int employerId;
  final int workerId;
  final int jobId;
  final String workerName;

  const RateWorkerScreen({
    Key? key,
    required this.employerId,
    required this.workerId,
    required this.jobId,
    required this.workerName,
  }) : super(key: key);

  @override
  State<RateWorkerScreen> createState() => _RateWorkerScreenState();
}

class _RateWorkerScreenState extends State<RateWorkerScreen> {
  int rating = 5;
  final TextEditingController commentController = TextEditingController();
  bool isSubmitting = false;

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  void submitRating() async {
    setState(() => isSubmitting = true);
    final token = await getToken();

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Oturum süresi dolmuş. Lütfen tekrar giriş yapın.")),
      );
      return;
    }

    final response = await http.post(
      Uri.parse("http://127.0.0.1:8000/ratings/"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'employer_id': widget.employerId,
        'worker_id': widget.workerId,
        'job_id': widget.jobId,
        'rating': rating,
        'comment': commentController.text.trim(),
        'receiver_id': widget.workerId,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Değerlendirme gönderildi.")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: ${response.body}")),
      );
    }

    setState(() => isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Çalışanı Değerlendir"),
        backgroundColor: const Color.fromARGB(255, 103, 144, 153),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CircleAvatar(radius: 45),
            const SizedBox(height: 12),
            Center(
              child: Text(
                widget.workerName,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
            _sectionTitle('Puanlama'),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 30,
                    ),
                    onPressed: () {
                      setState(() => rating = index + 1);
                    },
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),
            _sectionTitle('Yorumunuz'),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                hintText: "Yorum yazınız...",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: isSubmitting ? null : submitRating,
              icon: const Icon(Icons.send),
              label: const Text("Değerlendirmeyi Gönder"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 153, 199, 212),
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
