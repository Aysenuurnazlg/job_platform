import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  String _userId = '';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    print('Gelen argümanlar: $args');

    if (args != null && args is Map<String, dynamic>) {
      print('Argümanlar Map olarak alındı');
      _userId = args['id'].toString();
      _nameController.text = args['full_name'] ?? '';
      _emailController.text = args['email'] ?? '';
      _phoneController.text = args['phone_number'] ?? '';
      _bioController.text = args['bio'] ?? '';

      print('Yüklenen bilgiler:');
      print('ID: $_userId');
      print('İsim: ${_nameController.text}');
      print('Email: ${_emailController.text}');
      print('Telefon: ${_phoneController.text}');
      print('Bio: ${_bioController.text}');
    } else {
      print('Argümanlar Map değil veya null');
      // Eğer bilgiler gelmezse API'den al
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      print('Token: $token');

      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/users/me'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('API Yanıt Kodu: ${response.statusCode}');
      print('API Yanıtı: ${response.body}');

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        setState(() {
          _userId = userData['id'].toString();
          _nameController.text = userData['full_name'] ?? '';
          _emailController.text = userData['email'] ?? '';
          _phoneController.text = userData['phone_number'] ?? '';
          _bioController.text = userData['bio'] ?? '';
        });
        print('API\'den yüklenen bilgiler:');
        print('ID: $_userId');
        print('İsim: ${_nameController.text}');
        print('Email: ${_emailController.text}');
        print('Telefon: ${_phoneController.text}');
        print('Bio: ${_bioController.text}');
      } else {
        print('API Hatası: ${response.statusCode}');
      }
    } catch (e) {
      print('Veri yükleme hatası: $e');
    }
  }

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') ?? '';
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final token = await getToken();
      print('Mevcut token: $token');

      final url = Uri.parse('http://127.0.0.1:8000/users/$_userId');

      try {
        print('Gönderilen veriler:');
        final requestBody = {
          "email": _emailController.text,
          "full_name": _nameController.text,
          "phone_number": _phoneController.text,
          "bio": _bioController.text.isEmpty ? null : _bioController.text,
        };
        print(requestBody);

        final response = await http.put(
          url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: json.encode(requestBody),
        );

        if (!mounted) return;

        print('Backend yanıtı:');
        print('Status Code: ${response.statusCode}');
        print('Response Headers: ${response.headers}');
        print('Response Body: ${response.body}');

        final responseData = json.decode(response.body);
        final prefs = await SharedPreferences.getInstance();

        if (response.statusCode == 200 || response.statusCode == 201) {
          // E-posta değişikliği yapıldıysa yeni token al
          if (_emailController.text != prefs.getString('email')) {
            // Yeni token almak için login endpoint'ini kullan
            final loginResponse = await http.post(
              Uri.parse('http://127.0.0.1:8000/auth/login'),
              headers: {"Content-Type": "application/json"},
              body: json.encode({
                "username": _emailController.text,
                "password": prefs.getString('password') ?? '',
              }),
            );

            if (loginResponse.statusCode == 200) {
              final loginData = json.decode(loginResponse.body);
              if (loginData.containsKey('access_token')) {
                await prefs.setString(
                    'access_token', loginData['access_token']);
                print('Yeni token kaydedildi');
              }
            }
          }

          // Kullanıcı bilgilerini güncelle
          await prefs.setString('email', _emailController.text);
          await prefs.setString('full_name', _nameController.text);
          await prefs.setString('phone_number', _phoneController.text);
          await prefs.setString('bio', _bioController.text);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil başarıyla güncellendi'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          String errorMessage = 'Bir hata oluştu';
          if (responseData is Map) {
            if (responseData.containsKey('detail')) {
              errorMessage = responseData['detail'];
            } else if (responseData.containsKey('message')) {
              errorMessage = responseData['message'];
            }
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hata: $errorMessage'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } catch (e) {
        print('Hata detayı: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bağlantı hatası: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Düzenle'),
        backgroundColor: const Color.fromARGB(255, 103, 144, 153),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const CircleAvatar(
                radius: 40,
                child: Icon(Icons.camera_alt, size: 40),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Ad Soyad'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ad boş olamaz' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'E-posta'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'E-posta boş olamaz';
                  }
                  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                    return 'Geçerli bir e-posta girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration:
                    const InputDecoration(labelText: 'Telefon Numarası'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Telefon boş olamaz'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(labelText: 'Biyografi'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save),
                label: const Text('Güncelle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 153, 199, 212),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
