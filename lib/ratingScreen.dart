import 'package:flutter/material.dart';

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

  void submitRating() async {
    // API isteği buraya eklenebilir
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Değerlendirme gönderildi.")),
    );
    Navigator.pop(context);
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
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
              onPressed: submitRating,
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
