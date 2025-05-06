import 'package:flutter/material.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = 'Ahmet Yılmaz';
  String _email = 'ahmet.yilmaz@example.com';
  String _phone = '555-1234-5678';
  String _bio = 'Merhaba, ben Ahmet!';
  String _location = 'Ankara, Türkiye';
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Düzenle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                // Profil güncelleme işlemleri burada yapılabilir
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profil başarıyla güncellendi')),
                );
              }
            },
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
              // Profil Fotoğrafı
              GestureDetector(
                onTap: () {
                  // Profil fotoğrafı seçme işlemi
                },
                child: const CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage('https://www.example.com/profile.jpg'),
                  child: Icon(Icons.camera_alt, size: 50, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),

              // Ad
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Ad Soyad'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ad boş olamaz';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 16),

              // E-posta
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

              // Telefon Numarası
              TextFormField(
                initialValue: _phone,
                decoration: const InputDecoration(labelText: 'Telefon Numarası'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Telefon numarası boş olamaz';
                  }
                  return null;
                },
                onSaved: (value) => _phone = value!,
              ),
              const SizedBox(height: 16),

              // Biyografi
              TextFormField(
                initialValue: _bio,
                decoration: const InputDecoration(labelText: 'Biyografi'),
                onSaved: (value) => _bio = value!,
                maxLines: 3,
              ),
              const SizedBox(height: 16),


              // Bildirim Ayarı
              SwitchListTile(
                title: const Text('Bildirimleri Al'),
                value: _notificationsEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
              const SizedBox(height: 3),

              // Güncelle Butonu
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Profil güncelleme işlemleri burada yapılabilir
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profil başarıyla güncellendi')),
                    );
                  }
                },
                child: const Text('Güncelle'),
              ),

            
            ],
          ),
        ),
      ),
    );
  }
}
