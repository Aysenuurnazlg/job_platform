import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'config.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('access_token');
}

Future<int> submitApplication(int jobId, int userId) async {
  try {
    final token = await getToken(); // Token'ı al
    if (token == null) {
      throw Exception('Oturum süreniz dolmuş. Lütfen tekrar giriş yapın.');
    }

    final response = await http.post(
      Uri.parse(Config.jobApplicationUrl(jobId)),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({"user_id": userId}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      return responseData['id'];
    } else {
      final errorResponse = jsonDecode(response.body);
      throw Exception(
          'Başvuru gönderilemedi: ${errorResponse['detail'] ?? 'Bilinmeyen hata (${response.statusCode})'}');
    }
  } catch (e) {
    print('Başvuru hatası: $e'); // Hata ayıklama için
    rethrow;
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
  int? userId;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    jobId = args?['jobId'];

    // Kullanıcı ID'sini SharedPreferences'dan al
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('user_id');

    if (userId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Oturum süreniz dolmuş. Lütfen tekrar giriş yapın.')),
      );
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    fetchJobDetail(jobId);
  }

  Future<void> fetchJobDetail(int jobId) async {
    final url = Uri.parse(Config.jobDetailUrl(jobId));

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
      await submitApplication(jobId, userId!);

      if (!mounted) return;

      // Başarılı başvuru dialog'u
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 80,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Başvurunuz Başarıyla Gönderildi!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'İşveren başvurunuzu değerlendirdikten sonra size dönüş yapacaktır.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Dialog'u kapat
                      Navigator.of(context).pop(); // İlan detay sayfasını kapat
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF679099),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Tamam',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
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
