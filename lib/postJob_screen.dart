import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedJobType;
  String description = '';
  String fee = '';

  final List<String> jobTypes = [
    'Eczaneye Gitme',
    'Market Alışverişi',
    'Ev Temizliği',
    'Refakatçi',
  ];

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && selectedJobType != null) {
      _formKey.currentState!.save();

      final url = Uri.parse("http://127.0.0.1:8000/jobs?owner_id=1"); // sabit owner_id
      final jobData = {
        "title": selectedJobType,
        "description": description,
        "location": "Ankara", // sabit
        "salary": double.tryParse(fee) ?? 0.0,
      };

      try {
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: json.encode(jobData),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('İlan başarıyla verildi!')),
          );
          Navigator.pop(context);
        } else {
          if (!mounted) return;
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm alanları doldurun.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('İlan Ver'),
        backgroundColor: Colors.blueGrey.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    decoration: _inputDecoration('İş Türü'),
                    items: jobTypes.map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                    onChanged: (value) => setState(() => selectedJobType = value),
                    validator: (value) =>
                        value == null ? 'Lütfen iş türünü seçin' : null,
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    decoration: _inputDecoration('Açıklama'),
                    maxLines: 3,
                    onSaved: (value) => description = value ?? '',
                    validator: (value) => value == null || value.isEmpty
                        ? 'Lütfen açıklama girin'
                        : null,
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    decoration: _inputDecoration('Ücret (₺)').copyWith(
                      prefixText: '₺ ',
                    ),
                    keyboardType: TextInputType.number,
                    onSaved: (value) => fee = value ?? '',
                    validator: (value) => value == null || value.isEmpty
                        ? 'Lütfen ücret girin'
                        : null,
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey.shade800,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'İlanı Oluştur',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade200,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
