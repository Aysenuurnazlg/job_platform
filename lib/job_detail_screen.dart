import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'application.success.dart';
import 'config.dart';

Future<int> submitApplication(int jobId, int userId) async {
  final response = await http.post(
    Uri.parse(ApiConfig.jobApplicationUrl(jobId)),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    body: jsonEncode({"userId": 1}),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    final responseData = jsonDecode(response.body);
    return responseData['id'];
  } else {
    final errorResponse = jsonDecode(response.body);
    throw Exception(
        'Başvuru gönderilemedi: ${errorResponse['detail'] ?? 'Bilinmeyen hata'}');
  }
}

class JobDetailScreen extends StatefulWidget {
  const JobDetailScreen({super.key});

  @override
  JobDetailScreenState createState() => JobDetailScreenState();
}

class JobDetailScreenState extends State<JobDetailScreen> {
  Map<String, dynamic>? jobDetails;
  bool isLoading = true;
  late int jobId;
  late int userId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    jobId = args?['jobId'];
    userId = args?['userId'] ?? 1;

    fetchJobDetail(jobId);
  }

  Future<void> fetchJobDetail(int jobId) async {
    final url = Uri.parse(ApiConfig.jobDetailUrl(jobId));

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          jobDetails = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sunucu hatası: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bağlantı hatası: $e')),
      );
    }
  }

  void applyToJob() async {
    try {
      final applicationId = await submitApplication(jobId, userId);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ApplicationSuccessScreen(applicationId: applicationId),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      String errorMessage;

      if (e.toString().contains("Sunucu Hatası")) {
        errorMessage = "Başvuru gönderilemedi, sunucu hatası!";
      } else if (e.toString().contains("Bağlantı hatası")) {
        errorMessage =
            "Bağlantı hatası! Lütfen internet bağlantınızı kontrol edin.";
      } else {
        errorMessage = "Başvuru gönderilemedi. Lütfen tekrar deneyin.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İlan Detayları'),
        backgroundColor: const Color(0xFF679099),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : jobDetails == null
              ? const Center(child: Text('İlan verisi bulunamadı.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                jobDetails!['title'] ?? 'Başlık',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      color: Colors.grey),
                                  const SizedBox(width: 5),
                                  Text(
                                    jobDetails!['location'] ??
                                        'Konum belirtilmemiş',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.attach_money,
                                      color: Colors.green),
                                  const SizedBox(width: 5),
                                  Text(
                                    "₺${jobDetails!['salary']?.toStringAsFixed(0) ?? '0'}",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.date_range,
                                      color: Colors.blueGrey),
                                  const SizedBox(width: 5),
                                  Text(
                                    "Tarih: ${DateFormat('dd.MM.yyyy').format(DateTime.parse(jobDetails!['created_at'] ?? DateTime.now().toIso8601String()))}",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Açıklama",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF444444),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            jobDetails!['description'] ?? 'Açıklama yok.',
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: isLoading ? null : applyToJob,
                          icon: const Icon(Icons.send),
                          label: const Text("Başvur"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF679099),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 14),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
