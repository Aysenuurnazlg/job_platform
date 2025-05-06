import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    final email = _usernameController.text;
    final password = _passwordController.text;

    // Backend olmadan kontrol
    if (email == 'admin' && password == '1234') {
      Navigator.pushReplacementNamed(context, '/home');
      return;
    }

    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'username': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final token = responseData['access_token'];

      if (token != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showErrorDialog("Token alınamadı.");
      }
    } else {
      _showErrorDialog("Kullanıcı adı veya şifre yanlış.");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Giriş Başarısız"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tamam"),
          ),
        ],
      ),
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
                        child: Column(
                          children: [
                            TextField(
                              controller: _usernameController,
                              style: const TextStyle(fontSize: 18),
                              decoration: const InputDecoration(
                                labelText: 'E-Posta',
                                prefixIcon: Icon(Icons.person),
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 20),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              style: const TextStyle(fontSize: 18),
                              decoration: const InputDecoration(
                                labelText: 'Şifre',
                                prefixIcon: Icon(Icons.lock),
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 20),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  final TextEditingController emailController =
                                      TextEditingController();
                                  final TextEditingController
                                      newPasswordController =
                                      TextEditingController();
                                  final TextEditingController
                                      confirmPasswordController =
                                      TextEditingController();

                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text("Şifre Yenileme"),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextField(
                                            controller: emailController,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            decoration: const InputDecoration(
                                              labelText:
                                                  "E-posta adresinizi girin",
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          TextField(
                                            controller: newPasswordController,
                                            obscureText: true,
                                            decoration: const InputDecoration(
                                              labelText: "Yeni şifre oluşturun",
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          TextField(
                                            controller:
                                                confirmPasswordController,
                                            obscureText: true,
                                            decoration: const InputDecoration(
                                              labelText: "Şifreyi tekrar girin",
                                            ),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text("İptal"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            String email =
                                                emailController.text.trim();
                                            String newPassword =
                                                newPasswordController.text;
                                            String confirmPassword =
                                                confirmPasswordController.text;

                                            // Şifrelerin uyuşup uyuşmadığını kontrol et
                                            if (newPassword !=
                                                confirmPassword) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      "Girilen şifreler uyuşmuyor!"),
                                                ),
                                              );
                                              return;
                                            }

                                            // Güçlü şifre kontrolü (en az 6 karakter, en az bir rakam içermeli)
                                            RegExp passwordRegex =
                                                RegExp(r'^(?=.*\d).{6,}$');
                                            if (!passwordRegex
                                                .hasMatch(newPassword)) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    "Şifre çok zayıf! Şifrenizde en az 6 karakter ve bir rakam bulunmalıdır.",
                                                  ),
                                                ),
                                              );
                                              return;
                                            }

                                            // Şifre doğrulaması başarılı, işlemi gerçekleştir
                                            Navigator.pop(context);

                                            // Burada gerçek şifre güncelleme işlemi yapılabilir
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    "Yeni şifre belirlendi: $newPassword\n(E-posta: $email)"),
                                              ),
                                            );
                                          },
                                          child: const Text("Kaydet"),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: const Text("Şifremi unuttum"),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 103, 144, 153),
                                minimumSize: const Size(double.infinity, 55),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
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
