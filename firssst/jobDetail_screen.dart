import 'package:flutter/material.dart';

class JobDetailScreen extends StatelessWidget {
  const JobDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('İlan Detayları')),
      body: const Center(child: Text('İlan detayları burada gösterilecek.')),
    );
  }
}
