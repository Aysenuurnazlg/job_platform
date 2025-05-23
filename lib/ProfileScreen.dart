import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_screen.dart'; // settings_screen dosyanın adı buysa

// Renkleri burada da tanımlayabilir veya ayrı bir theme/color dosyası oluşturabilirsin
const MaterialColor customPrimaryColor = MaterialColor(
  0xFF678F99,
  <int, Color>{
    50: Color(0xFFE9EEF0),
    100: Color(0xFFC7D4D8),
    200: Color(0xFFA0B6BF),
    300: Color(0xFF7A97A6),
    400: Color(0xFF678F99),
    500: Color(0xFF547E8C),
    600: Color(0xFF4C7582),
    700: Color(0xFF406976),
    800: Color(0xFF355E6B),
    900: Color(0xFF234B5A),
  },
);

const Color accentOrange = Color(0xFFFFB74D);
const Color backgroundLightGrey = Color(0xFFF4F7F8);
const Color textDark = Color(0xFF333333);
const Color textMedium = Color(0xFF666666);
const Color textLight = Color(0xFF999999);

class ProfileScreen extends StatefulWidget {
  final int? userId;
  final bool isOwnProfile;

  const ProfileScreen({
    super.key,
    this.userId,
    this.isOwnProfile = true,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _profileFuture;

  @override
  void initState() {
    super.initState();
    // userId null olmaması durumunu kontrol et. Genellikle login sonrası olacağı varsayılır.
    if (widget.userId == null && widget.isOwnProfile) {
      _loadOwnUserIdAndProfile();
    } else {
      _loadProfileData();
    }
  }

  // Kendi profilini görüntülerken userId'yi shared preferences'tan alma
  Future<void> _loadOwnUserIdAndProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final int? ownUserId = prefs.getInt('user_id'); // userId'yi burada sakladığını varsayıyorum
    if (ownUserId != null) {
      setState(() {
        _profileFuture = fetchProfileData(ownUserId);
      });
    } else {
      // Hata durumu: userId bulunamadı
      setState(() {
        _profileFuture = Future.error('Kullanıcı ID\'si bulunamadı.');
      });
    }
  }

  void _loadProfileData() {
    if (widget.userId != null) {
      setState(() {
        _profileFuture = fetchProfileData(widget.userId!);
      });
    } else {
      // Eğer userId dışarıdan gelmiyorsa (yani kendi profili değilse ve userId null ise)
      setState(() {
        _profileFuture = Future.error('Geçersiz kullanıcı ID\'si.');
      });
    }
  }

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') ?? '';
  }

  Future<Map<String, dynamic>> fetchProfileData(int id) async {
    try {
      final token = await getToken();
      final url = widget.isOwnProfile
          ? 'http://127.0.0.1:8000/users/me'
          : 'http://127.0.1:8000/users/$id'; // Dikkat: Buradaki IP adresini uygulamanın çalıştığı ortama göre ayarlamalısın. Genellikle mobil cihazlarda '10.0.2.2' veya gerçek IP kullanılır.

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes)); // Türkçe karakterler için utf8 decode
      } else if (response.statusCode == 404) {
        throw Exception('Kullanıcı bulunamadı.');
      } else if (response.statusCode == 401) {
        throw Exception('Yetkilendirme hatası. Lütfen tekrar giriş yapın.');
      } else {
        throw Exception(
            'Kullanıcı bilgileri alınamadı: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Profil bilgileri alınırken bir hata oluştu: $e'); // Hata ayıklama için
      throw Exception('Profil bilgileri alınırken bir hata oluştu: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLightGrey, // Genel arka plan rengi
      appBar: AppBar(
        title: Text(
          widget.isOwnProfile ? 'Profilim' : 'Profil',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor:const Color.fromRGBO(74, 109, 124, 1), // AppBar rengi
        elevation: 0, // Gölgeyi kaldır
        actions: [
          if (widget.isOwnProfile)
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SettingsScreen(userId: widget.userId!), // userId'nin null olmadığını varsayıyoruz
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              // Kendi profilini görüntülerken userId'yi shared preferences'tan alma
              if (widget.isOwnProfile) {
                _loadOwnUserIdAndProfile();
              } else {
                _loadProfileData();
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: customPrimaryColor));
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.sentiment_dissatisfied_outlined, // Daha modern bir ikon
                      color: customPrimaryColor, // Hata ikon rengi
                      size: 70,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Üzgünüz, bir hata oluştu:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 17, color: textMedium),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Kendi profilini görüntülerken userId'yi shared preferences'tan alma
                        if (widget.isOwnProfile) {
                          _loadOwnUserIdAndProfile();
                        } else {
                          _loadProfileData();
                        }
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tekrar Dene'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: customPrimaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final profileData = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24), // Genel sayfa boşluğu artırıldı
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, // Ortalamak için
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15), // Hafif bir gölge
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 60, // Avatar boyutu büyütüldü
                    backgroundColor: customPrimaryColor.shade100, // Varsayılan arka plan
                    backgroundImage: profileData['profile_picture_url'] != null
                        ? NetworkImage(profileData['profile_picture_url'])
                        : null, // Profil resmi URL'si varsa kullan
                    child: profileData['profile_picture_url'] == null
                        ? Icon(Icons.person, size: 70, color: customPrimaryColor.shade400) // Varsayılan ikon
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  profileData['full_name'] ?? 'Bilinmiyor', // null kontrolü eklendi
                  style: const TextStyle(
                      fontSize: 28, // Başlık font boyutu büyütüldü
                      fontWeight: FontWeight.bold,
                      color: textDark,
                      letterSpacing: -0.5 // Hafif sıkı harf aralığı
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  profileData['bio'] ?? 'Henüz biyografi eklenmedi.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: textMedium,
                      height: 1.4 // Satır yüksekliği ayarlandı
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _infoCard(
                      title: 'Aldığı İş',
                      value: '${profileData['completed_jobs'] ?? 0}',
                      icon: Icons.work, // İkon eklendi
                      iconColor: customPrimaryColor,
                    ),
                    _infoCard(
                      title: 'Puan',
                      value: (profileData['rating'] ?? 0.0).toStringAsFixed(1),
                      icon: Icons.star_rounded, // Yuvarlak yıldız ikonu
                      iconColor: accentOrange, // Turuncu vurgu rengi
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                _sectionTitle('Aldığı İş Türleri'),
                Wrap(
                  spacing: 10, // Chip'ler arası boşluk
                  runSpacing: 8,
                  children: (profileData['job_types'] ?? [])
                      .map<Widget>((type) => Chip(
                            label: Text(
                              type,
                              style: TextStyle(color: customPrimaryColor.shade800, fontWeight: FontWeight.w600),
                            ),
                            backgroundColor: customPrimaryColor.shade100, // Chip rengi
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            elevation: 1,
                          ))
                      .toList(),
                ),
                const SizedBox(height: 40),
                _sectionTitle('Yorumlar'),
                if ((profileData['reviews'] ?? []).isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Henüz hiç yorum yapılmamış.',
                      style: TextStyle(fontSize: 16, color: textMedium),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ...((profileData['reviews'] ?? []) as List)
                    .map<Widget>((review) => Card(
                          margin: const EdgeInsets.symmetric(vertical: 8), // Dikey boşluk
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)), // Daha yuvarlak köşeler
                          elevation: 6, // Daha belirgin gölge
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0), // İç boşluk
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      review['name'] ?? 'Anonim Kullanıcı',
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: textDark),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: List.generate(
                                        5,
                                        (index) => Icon(
                                          index < (review['rating'] ?? 0)
                                              ? Icons.star_rounded
                                              : Icons.star_border_rounded,
                                          color: accentOrange, // Turuncu yıldızlar
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  review['comment'] ?? 'Yorum bulunamadı.',
                                  style: const TextStyle(fontSize: 15, color: textMedium),
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    'Yorum Tarihi: ${review['date'] ?? 'Bilinmiyor'}', // null kontrolü
                                    style: const TextStyle(fontSize: 12, color: textLight),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                const SizedBox(height: 40),
                if (widget.isOwnProfile)
                  SizedBox(
                    width: double.infinity, // Butonu tam genişlik yap
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.pushNamed(
                          context,
                          '/profileEdit',
                          arguments: {
                            'id': widget.userId,
                            'full_name': profileData['full_name'],
                            'email': profileData['email'],
                            'phone_number': profileData['phone_number'],
                            'bio': profileData['bio'] ?? '',
                          },
                        );

                        if (result == true) {
                          // Kendi profilini görüntülerken userId'yi shared preferences'tan alma
                          if (widget.isOwnProfile) {
                            _loadOwnUserIdAndProfile();
                          } else {
                            _loadProfileData(); // veriyi yeniden yükle
                          }
                        }
                      },
                      icon: const Icon(Icons.edit_rounded, size: 24), // Yuvarlak ikon
                      label: const Text(
                        'Profili Düzenle',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: customPrimaryColor, // Ana renk
                        foregroundColor: Colors.white, // Yazı rengi
                        padding: const EdgeInsets.symmetric(vertical: 18), // Dikey boşluk
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // Daha yuvarlak kenarlar
                        ),
                        elevation: 5, // Hafif gölge
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoCard({
    required String title,
    required String value,
    IconData? icon,
    Color? iconColor,
  }) {
    return Card(
      elevation: 6, // Daha belirgin gölge
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), // Daha yuvarlak köşeler
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4, // Ekran genişliğine göre boyutlandırma
        height: 100, // Yükseklik artırıldı
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, // İçerik kartı arka planı
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200), // Hafif kenarlık
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 15, color: textMedium, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 22, color: iconColor ?? textDark),
                  const SizedBox(width: 6),
                ],
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 24, // Değer font boyutu büyütüldü
                      fontWeight: FontWeight.bold,
                      color: textDark),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12), // Boşluk artırıldı
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 22, // Bölüm başlığı boyutu
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
      ),
    );
  }
}