import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yardım ve Destek')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Yardım almak için bizimle iletişime geçebilirsiniz.\n\n'
          'E-posta: destek@uygulama.com\n'
          'Telefon: 0123 456 78 90',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
