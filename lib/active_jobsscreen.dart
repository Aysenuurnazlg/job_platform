import 'package:flutter/material.dart';
import 'ratingScreen.dart';
import 'ProfileScreen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MyActiveJobsScreen extends StatefulWidget {
  final int employerId;
  const MyActiveJobsScreen({Key? key, required this.employerId})
      : super(key: key);

  @override
  State<MyActiveJobsScreen> createState() => _MyActiveJobsScreenState();
}

class _MyActiveJobsScreenState extends State<MyActiveJobsScreen>
    with SingleTickerProviderStateMixin {
  List allJobs = [];
  List activeJobs = [];
  bool isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchData();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<void> fetchData() async {
    try {
      final token = await getToken();
      if (token == null)
        throw Exception('Oturum süreniz dolmuş. Lütfen tekrar giriş yapın.');

      // Tüm işleri al
      final allJobsResponse = await http.get(
        Uri.parse(
            'http://127.0.0.1:8000/employer/${widget.employerId}/all-jobs'),
        headers: {'Authorization': 'Bearer $token'},
      );

      // Aktif işleri al
      final activeJobsResponse = await http.get(
        Uri.parse('http://127.0.0.1:8000/employer/${widget.employerId}/jobs'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (allJobsResponse.statusCode == 200 &&
          activeJobsResponse.statusCode == 200) {
        final List allJobsData = json.decode(allJobsResponse.body);
        final List activeJobsData = json.decode(activeJobsResponse.body);

        print('Tüm işler: $allJobsData'); // Debug için
        print('Aktif işler: $activeJobsData'); // Debug için

        setState(() {
          allJobs = allJobsData;
          activeJobs =
              activeJobsData.where((job) => job['worker_id'] != null).toList();
          isLoading = false;
        });

        print('Filtrelenmiş aktif işler: $activeJobs'); // Debug için
      } else {
        throw Exception('Veriler alınamadı');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Veri alınamadı: $e')));
    }
  }

  Future<void> approveApplication(int applicationId, int userId) async {
    try {
      final token = await getToken();
      if (token == null)
        throw Exception('Oturum süreniz dolmuş. Lütfen tekrar giriş yapın.');

      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/applications/$applicationId/approve'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Başvuru onaylandı')));
        await fetchData();
      } else {
        throw Exception('Başvuru onaylanamadı');
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Hata: $e')));
    }
  }

  Future<void> completeJob(int jobId, int workerId, String workerName) async {
    try {
      final token = await getToken();
      if (token == null)
        throw Exception('Oturum süreniz dolmuş. Lütfen tekrar giriş yapın.');

      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/jobs/$jobId/complete'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('İş tamamlandı olarak işaretlendi')),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RateWorkerScreen(
              employerId: widget.employerId,
              workerId: workerId,
              jobId: jobId,
              workerName: workerName,
            ),
          ),
        );
      } else {
        throw Exception('İş tamamlanamadı');
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Hata: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("İlanlarım"),
        backgroundColor: const Color.fromARGB(255, 103, 144, 153),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Tüm İlanlarım"),
            Tab(text: "Aktif İlanlar"),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Tüm İlanlarım Sekmesi
                ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: allJobs.length,
                  itemBuilder: (context, index) {
                    final job = allJobs[index];
                    final basvuranlar = job['basvuranlar'] ?? [];

                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text(job['title'] ?? 'Başlık yok'),
                            subtitle:
                                Text(job['description'] ?? 'Açıklama yok'),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 16.0, top: 8),
                            child: Text("Başvuranlar:",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                          ...basvuranlar.map<Widget>((basvuran) {
                            final kullanici = basvuran['kullanici'] ?? {};
                            return ListTile(
                              leading: CircleAvatar(
                                child: Text(
                                    kullanici['isim']?.substring(0, 1) ?? '?'),
                              ),
                              title: Text(kullanici['isim'] ?? 'İsimsiz'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Puan: ${kullanici['ortalama_puan'] ?? '-'}'),
                                  Text(
                                      'Tarih: ${basvuran['basvuru_tarihi'] ?? 'Yok'}'),
                                ],
                              ),
                              trailing: Wrap(
                                spacing: 8,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.person),
                                    tooltip: 'Profili Gör',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ProfileScreen(
                                            userId: kullanici['id'],
                                            isOwnProfile: false,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon:
                                        const Icon(Icons.check_circle_outline),
                                    color: Colors.green,
                                    tooltip: 'Onayla',
                                    onPressed: () => approveApplication(
                                      basvuran['basvuru_id'],
                                      kullanici['id'],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    );
                  },
                ),

                // Aktif İlanlar Sekmesi
                ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: activeJobs.length,
                  itemBuilder: (context, index) {
                    final job = activeJobs[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // İş Başlığı ve Açıklaması
                          ListTile(
                            title: Text(
                              job['title'] ?? 'Başlık yok',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle:
                                Text(job['description'] ?? 'Açıklama yok'),
                          ),

                          // Çalışan Bilgileri
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(12),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Çalışan Bilgileri",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color.fromARGB(255, 103, 144, 153),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: const Color.fromARGB(
                                          255, 103, 144, 153),
                                      child: Text(
                                        (job['worker_name'] ?? '?')[0]
                                            .toUpperCase(),
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            job['worker_name'] ?? 'İsimsiz',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            'İş Durumu: ${job['is_completed'] ? 'Tamamlandı' : 'Devam Ediyor'}',
                                            style: TextStyle(
                                              color: job['is_completed']
                                                  ? Colors.green
                                                  : Colors.orange,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.person),
                                      color: const Color.fromARGB(
                                          255, 103, 144, 153),
                                      tooltip: 'Çalışan Profilini Gör',
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ProfileScreen(
                                              userId: job['worker_id'],
                                              isOwnProfile: false,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Değerlendirme Butonu
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.star),
                                    label: const Text(
                                        'İşi Tamamla ve Değerlendir'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                          255, 103, 144, 153),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () => completeJob(
                                      job['id'],
                                      job['worker_id'],
                                      job['worker_name'] ?? 'İsimsiz',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }
}
