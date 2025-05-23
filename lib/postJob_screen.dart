import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PostJobScreen extends StatefulWidget {
  final int userId;
  const PostJobScreen({super.key, required this.userId});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedJobType;
  String description = '';
  String fee = '';
  String location = '';
  DateTime? selectedDateTime;
  String? _token;

  final List<String> jobTypes = [
    'Eczaneye gitme',
    'Markete gitme',
    'Ev Temizliği',
    'Refakatçi',
    'Ulaşım Hizmetleri',
    'Sosyal Destek'
  ];

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('access_token');
    });
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    setState(() {
      selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() &&
        selectedJobType != null &&
        selectedDateTime != null) {
      _formKey.currentState!.save();

      if (_token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Oturum süreniz dolmuş. Lütfen tekrar giriş yapın.')),
        );
        return;
      }

      final url = Uri.parse("http://127.0.0.1:8000/jobs/");

      final jobData = {
        "title": selectedJobType,
        "description": description,
        "salary": double.tryParse(fee) ?? 0.0,
        "location": location,
      };

      try {
        final response = await http.post(
          url,
          headers: {
            "Content-Type": "application/json; charset=utf-8",
            "Authorization": "Bearer $_token"
          },
          body: jsonEncode(jobData),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('İlanınız başarıyla oluşturuldu.')),
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
        backgroundColor: const Color.fromRGBO(74, 109, 124, 1),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    onChanged: (value) =>
                        setState(() => selectedJobType = value),
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
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration:
                        _inputDecoration('Konum (örnek: Ankara / Çankaya)'),
                    onSaved: (value) => location = value ?? '',
                    validator: (value) => value == null || value.isEmpty
                        ? 'Lütfen konum girin'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedDateTime == null
                              ? 'Tarih ve saat seçilmedi'
                              : 'Seçilen: ${selectedDateTime.toString()}',
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _pickDateTime,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 103, 144, 153),
                        ),
                        child: const Text('Tarih & Saat Seç'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 103, 144, 153),
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
