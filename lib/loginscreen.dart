import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'register_screen.dart';
import 'config.dart'; // api_config olarak isimlendirdim

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(); // <-- düzeltildi
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(Config.tokenUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'username': _usernameController.text,
          'password': _passwordController.text,
        },
      );

      print("LOGIN RESPONSE STATUS: ${response.statusCode}");
      print("LOGIN RESPONSE BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', token);

        final userResponse = await http.get(
          Uri.parse('${Config.meUrl}'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        print("ME RESPONSE STATUS: ${userResponse.statusCode}");
        print("ME RESPONSE BODY: ${userResponse.body}");

        if (userResponse.statusCode == 200) {
          final userData = jsonDecode(userResponse.body);
          await prefs.setInt('user_id', userData['id']);

          if (!mounted) return;
          Navigator.pushReplacementNamed(
            context,
            '/home',
            arguments: userData['id'],
          );
        } else {
          throw Exception('Kullanıcı bilgileri alınamadı');
        }
      } else if (response.statusCode == 401) {
        _showError('Geçersiz e-posta veya şifre.');
      } else {
        _showError('Giriş başarısız. Lütfen bilgilerinizi kontrol edin.');
      }
    } catch (e) {
      _showError('Bağlantı hatası: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF2F5),
      body: Stack(
        children: [
          ClipPath(
            clipper: TopWaveClipper(),
            child: Container(
              height: 300,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 103, 144, 153),
                    Color.fromARGB(255, 49, 71, 78)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Text(
                  'Giriş Yap',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 180),
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _usernameController,
                                validator: (value) =>
                                    value!.isEmpty ? 'E-posta giriniz' : null,
                                decoration: const InputDecoration(
                                  labelText: 'E-Posta',
                                  prefixIcon: Icon(Icons.person),
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 20),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                validator: (value) =>
                                    value!.isEmpty ? 'Şifre giriniz' : null,
                                decoration: const InputDecoration(
                                  labelText: 'Şifre',
                                  prefixIcon: Icon(Icons.lock),
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 20),
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 103, 144, 153),
                                  minimumSize: const Size(double.infinity, 55),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text(
                                        "Giriş Yap",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterScreen()),
                        );
                      },
                      child: const Text(
                        "Hesabın yok mu? Kayıt Ol",
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 100);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 100);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
