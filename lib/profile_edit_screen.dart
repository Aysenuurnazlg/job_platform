import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  String _userId = '';
  String _name = '';
  String _email = '';
  String _phone = '';
  String _bio = '';
  bool _notificationsEnabled = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      _userId = args['id'].toString();
      _name = args['full_name'] ?? '';
      _email = args['email'] ?? '';
      _phone = args['phone_number'] ?? '';
      _bio = args['bio'] ?? '';
    } else {
      // ❗ Geçici varsayılan veriler — test için
      debugPrint(
          'Uyarı: arguments boş veya geçersiz! Sahte veri kullanılıyor.');
      _userId = '0';
      _name = 'Deneme Kullanıcı';
      _email = 'deneme@example.com';
      _phone = '5551234567';
      _bio = 'Bu bir test biyografisidir.';
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final url = Uri.parse('http://127.0.0.1:8000/users/$_userId');

      try {
        final response = await http.put(
          url,
          headers: {"Content-Type": "application/json"},
          body: json.encode({
            "email": _email,
            "full_name": _name,
            "phone_number": _phone,
            "bio": _bio,
          }),
        );

        if (!mounted) return;

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil başarıyla güncellendi')),
          );
          Navigator.pop(
              context, true); // Profil ekranını yenilemek için true döndür
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hata: ${response.body}')),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bağlantı hatası: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Düzenle'),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                child: Icon(Icons.camera_alt, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Ad Soyad'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ad boş olamaz' : null,
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _email,
                decoration: const InputDecoration(labelText: 'E-posta'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'E-posta boş olamaz';
                  }
                  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                    return 'Geçerli bir e-posta adresi girin';
                  }
                  return null;
                },
                onSaved: (value) => _email = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _phone,
                decoration:
                    const InputDecoration(labelText: 'Telefon Numarası'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Telefon numarası boş olamaz'
                    : null,
                onSaved: (value) => _phone = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _bio,
                decoration: const InputDecoration(labelText: 'Biyografi'),
                onSaved: (value) => _bio = value!,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Bildirimleri Al'),
                value: _notificationsEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text('Güncelle'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
