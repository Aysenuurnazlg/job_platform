import 'package:flutter/material.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedJobType;
  String description = '';
  String location = '';

  final List<String> jobTypes = [
    'Eczaneye Gitme',
    'Market Alışverişi',
    'Ev Temizliği',
    'Refakatçi',
  ];

  void _submitForm() {
    if (_formKey.currentState!.validate() && selectedJobType != null) {
      _formKey.currentState!.save();

      // Burada verileri backend'e gönderebilirsin
      debugPrint('İş Türü: $selectedJobType');
      debugPrint('Açıklama: $description');
      debugPrint('Konum: $location');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İlan başarıyla verildi!')),
      );

      // Geri ana sayfaya yönlendirme (isteğe bağlı)
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm alanları doldurun.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String fee = '';
    return Scaffold(
      appBar: AppBar(
        title: const Text('İlan Ver'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // İş türü seçimi
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'İş Türü'),
                items: jobTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedJobType = value;
                  });
                },
                validator: (value) => value == null ? 'Lütfen iş türünü seçin' : null,
              ),

              const SizedBox(height: 16),

              // Açıklama alanı
              TextFormField(
                decoration: const InputDecoration(labelText: 'Açıklama'),
                maxLines: 3,
                onSaved: (value) => description = value ?? '',
                validator: (value) =>
                    value == null || value.isEmpty ? 'Lütfen açıklama girin' : null,
              ),

              const SizedBox(height: 16),

              // // Konum bilgisi
              // TextFormField(
              //   decoration: const InputDecoration(labelText: 'Konum'),
              //   onSaved: (value) => location = value ?? '',
              //   validator: (value) =>
              //       value == null || value.isEmpty ? 'Lütfen konum bilgisi girin' : null,
              // ),

              // const SizedBox(height: 30),
               TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Ücret (₺)',
                  prefixText: '₺ ',
                ),
                keyboardType: TextInputType.number,
                onSaved: (value) => fee = value ?? '',
                validator: (value) =>
                    value == null || value.isEmpty ? 'Lütfen ücret girin' : null,
              ),

              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('İlanı Oluştur'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
