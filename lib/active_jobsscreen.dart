import 'package:flutter/material.dart';
import 'ratingScreen.dart';
import 'ProfileScreen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// --- Renk Paleti Tanımlamaları ---
const Color primarySteelBlue = Color(0xFF4A6D7C); // Ana renk
const Color accentWarmOrange = Color(0xFFFFAB40); // Vurgu rengi 1 (Onay, yıldızlar)
const Color accentTurquoise = Color(0xFF6CC7C7); // Vurgu rengi 2 (Durum, ikincil)
const Color backgroundLight = Color(0xFFF5F8FA); // Genel arka plan
const Color cardWhite = Color(0xFFFFFFFF); // Kart arka planı
const Color textDark = Color(0xFF2C3E50); // Koyu yazı
const Color textMedium = Color(0xFF556C7D); // Orta yazı
const Color textLight = Color(0xFF8FA0AD); // Açık yazı
const Color statusCompleted = Colors.green; // Tamamlandı durumu için
const Color statusInProgress = Colors.orange; // Devam ediyor durumu için

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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<void> fetchData() async {
    // isLoading durumunu tekrar yükleme başlangıcında ayarlayalım
    setState(() {
      isLoading = true;
    });
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
        final List allJobsData = json.decode(utf8.decode(allJobsResponse.bodyBytes));
        final List activeJobsData = json.decode(utf8.decode(activeJobsResponse.bodyBytes));

        print('Tüm işler: $allJobsData'); // Debug için
        print('Aktif işler: $activeJobsData'); // Debug için

        setState(() {
          allJobs = allJobsData;
          activeJobs = activeJobsData.where((job) => job['worker_id'] != null).toList();
          isLoading = false;
        });

        print('Filtrelenmiş aktif işler: $activeJobs'); // Debug için
      } else {
        throw Exception('Veriler alınamadı: ${allJobsResponse.statusCode} - ${activeJobsResponse.statusCode}');
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar('Veri alınamadı: $e'); // SnackBar çağrısı güncellendi
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
        _showSnackBar('Başvuru onaylandı'); // SnackBar çağrısı güncellendi
        await fetchData(); // Verileri yenile
      } else {
        final errorBody = json.decode(utf8.decode(response.bodyBytes)); // Hata detayını al
        throw Exception('Başvuru onaylanamadı: ${errorBody['detail'] ?? response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('Hata: $e'); // SnackBar çağrısı güncellendi
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
        _showSnackBar('İş tamamlandı olarak işaretlendi'); // SnackBar çağrısı güncellendi
        // Burada await fetchData(); yok çünkü rateWorkerScreen'e gittikten sonra geri dönünce yenilenecek.
        // Eğer geri dönmeden yenilenmesini istersen buraya ekleyebilirsin.

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
        final errorBody = json.decode(utf8.decode(response.bodyBytes)); // Hata detayını al
        throw Exception('İş tamamlanamadı: ${errorBody['detail'] ?? response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('Hata: $e'); // SnackBar çağrısı güncellendi
    }
  }

  // Yeni _showSnackBar yardımcı fonksiyonu
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3), // Gösterim süresi
        behavior: SnackBarBehavior.floating, // Daha modern görünüm
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10), // Köşelerden boşluk
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight, // Genel arka plan rengi
      appBar: AppBar(
        title: const Text(
          "İlanlarım",
          style: TextStyle(
            color: cardWhite,
            fontWeight: FontWeight.bold,
            fontSize: 22, // Daha büyük başlık
          ),
        ),
        backgroundColor: const Color.fromRGBO(74, 109, 124, 1), // AppBar rengi
        elevation: 0, // Gölgeyi kaldır
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: accentWarmOrange, // Seçili tabın altındaki çizgi
          labelColor: cardWhite, // Seçili tab yazısı
          unselectedLabelColor: cardWhite.withOpacity(0.7), // Seçili olmayan tab yazısı
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
          tabs: const [
            Tab(text: "Tüm İlanlarım"),
            Tab(text: "Aktif İlanlar"),
          ],
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: primarySteelBlue),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                // --- Tüm İlanlarım Sekmesi ---
                _buildAllJobsTab(),
                // --- Aktif İlanlar Sekmesi ---
                _buildActiveJobsTab(),
              ],
            ),
    );
  }

  Widget _buildAllJobsTab() {
    if (allJobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, size: 80, color: textLight),
            const SizedBox(height: 20),
            const Text(
              'Henüz yayınlanmış bir ilanınız yok.',
              style: TextStyle(fontSize: 18, color: textMedium),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: fetchData, // Yenileme butonu
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Yenile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primarySteelBlue,
                foregroundColor: cardWhite,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16), // Genel padding artırıldı
      itemCount: allJobs.length,
      itemBuilder: (context, index) {
        final job = allJobs[index];
        final basvuranlar = job['basvuranlar'] ?? [];
        final hasApplications = basvuranlar.isNotEmpty;

        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Daha yuvarlak köşeler
          elevation: 5, // Daha belirgin gölge
          margin: const EdgeInsets.symmetric(vertical: 10), // Dikey boşluk artırıldı
          color: cardWhite, // Kart arka planı
          child: Padding(
            padding: const EdgeInsets.all(16.0), // İç padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job['title'] ?? 'Başlık Yok',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: textDark),
                ),
                const SizedBox(height: 8),
                Text(
                  job['description'] ?? 'Açıklama Yok',
                  style: const TextStyle(fontSize: 15, color: textMedium),
                ),
                const SizedBox(height: 15),
                // İş Durumu Çipi
                _buildJobStatusChip(job),
                const SizedBox(height: 15),
                Text(
                  hasApplications ? "Başvuranlar:" : "Henüz başvuru yok.",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: hasApplications ? textDark : textLight),
                ),
                if (hasApplications) const SizedBox(height: 10),
                ...basvuranlar.map<Widget>((basvuran) {
                  final kullanici = basvuran['kullanici'] ?? {};
                  return _buildApplicantTile(basvuran, kullanici); // job id'yi bu fonksiyona göndermeye gerek kalmadı
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveJobsTab() {
    if (activeJobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hourglass_empty_rounded, size: 80, color: textLight),
            const SizedBox(height: 20),
            const Text(
              'Devam eden aktif ilanınız yok.',
              style: TextStyle(fontSize: 18, color: textMedium),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: fetchData, // Yenileme butonu
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Yenile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primarySteelBlue,
                foregroundColor: cardWhite,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activeJobs.length,
      itemBuilder: (context, index) {
        final job = activeJobs[index];
        final isCompleted = job['is_completed'] ?? false;

        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 5,
          margin: const EdgeInsets.symmetric(vertical: 10),
          color: cardWhite,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job['title'] ?? 'Başlık Yok',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20, color: textDark),
                ),
                const SizedBox(height: 8),
                Text(
                  job['description'] ?? 'Açıklama Yok',
                  style: const TextStyle(fontSize: 15, color: textMedium),
                ),
                const SizedBox(height: 15),
                // Çalışan Bilgileri Kartı
                _buildWorkerInfoCard(job, isCompleted),
                if (!isCompleted) ...[ // İş tamamlanmadıysa butonu göster
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.star_half_rounded),
                      label: const Text('İşi Tamamla ve Değerlendir'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentWarmOrange, // Turuncu buton
                        foregroundColor: cardWhite,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      onPressed: () => completeJob(
                        job['id'],
                        job['worker_id'],
                        job['worker_name'] ?? 'İsimsiz',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // Başvuranları gösteren yardımcı widget
  Widget _buildApplicantTile(Map<String, dynamic> basvuran, Map<String, dynamic> kullanici) {
    return Card(
      elevation: 1, // Daha hafif gölge
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: backgroundLight, // Hafif gri arka plan
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: primarySteelBlue.withOpacity(0.1), // Hafif opak primary rengi
          child: Text(
            (kullanici['isim'] ?? '?').substring(0, 1).toUpperCase(),
            style: const TextStyle(color: primarySteelBlue, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          kullanici['isim'] ?? 'İsimsiz',
          style: const TextStyle(fontWeight: FontWeight.bold, color: textDark),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Puan: ${kullanici['ortalama_puan']?.toStringAsFixed(1) ?? '-'}',
                style: const TextStyle(color: textMedium, fontSize: 13)),
            Text('Başvuru Tarihi: ${basvuran['basvuru_tarihi']?.split('T')[0] ?? 'Yok'}', // Tarihi kısalt
                style: const TextStyle(color: textLight, fontSize: 12)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min, // İçeriğe göre genişlik
          children: [
            IconButton(
              icon: const Icon(Icons.person_outline_rounded),
              color: primarySteelBlue,
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
              icon: const Icon(Icons.check_circle_rounded),
              color: accentWarmOrange, // Turuncu onay butonu
              tooltip: 'Onayla',
              onPressed: () => approveApplication(
                basvuran['basvuru_id'],
                kullanici['id'],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Çalışan bilgilerini gösteren yardımcı widget
  Widget _buildWorkerInfoCard(Map<String, dynamic> job, bool isCompleted) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundLight, // Kartın alt kısmı için farklı arka plan
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textLight.withOpacity(0.2)), // Hafif bir kenarlık
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Atanmış Çalışan",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: primarySteelBlue,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 28, // Avatar boyutu büyütüldü
                backgroundColor: primarySteelBlue.withOpacity(0.7),
                child: Text(
                  (job['worker_name'] ?? '?')[0].toUpperCase(),
                  style: const TextStyle(color: cardWhite, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job['worker_name'] ?? 'İsimsiz Çalışan',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // İş Durumu Çipi (Daha belirgin)
                    _buildJobStatusChip(job),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.person_rounded),
                color: primarySteelBlue,
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
        ],
      ),
    );
  }

  // İş durumunu gösteren Chip yardımcı widget'ı
  Widget _buildJobStatusChip(Map<String, dynamic> job) {
    final bool isCompleted = job['is_completed'] ?? false;
    final bool hasWorker = job['worker_id'] != null;

    String statusText;
    Color statusColor;
    Color textColor;

    // Burada MaterialColor.shade özelliğini kullanmadan direkt renk değerlerini ayarladım
    if (isCompleted) {
      statusText = 'Tamamlandı';
      statusColor = statusCompleted.withOpacity(0.15); // Hafif yeşil
      textColor = statusCompleted.withOpacity(0.8); // Koyu yeşil
    } else if (hasWorker) {
      statusText = 'Devam Ediyor';
      statusColor = statusInProgress.withOpacity(0.15); // Hafif turuncu
      textColor = statusInProgress.withOpacity(0.8); // Koyu turuncu
    } else {
      statusText = 'Bekliyor';
      statusColor = primarySteelBlue.withOpacity(0.1); // Hafif primary
      textColor = primarySteelBlue.withOpacity(0.8); // Koyu primary
    }

    return Chip(
      label: Text(
        statusText,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
      backgroundColor: statusColor,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: textColor.withOpacity(0.3), width: 1), // Hafif kenarlık
      ),
      elevation: 0, // Çiplerde gölgeye gerek yok
    );
  }
}