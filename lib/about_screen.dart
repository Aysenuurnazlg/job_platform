import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hakkında'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Engelli ve Yaşlılara Yardımcı İş Platformu',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Engelli ve Yaşlılara Yardımcı İş Platformu, yaşlı ve engelli bireylerin günlük hayatlarını kolaylaştırmak amacıyla geliştirilmiş bir mobil uygulamadır. '
                'Kullanıcılar, market alışverişi, eczane işleri gibi günlük görevler için ilan oluşturabilir; bu ilanlara öğrenciler başvurarak görevleri yerine getirebilir. '
                'Sistem, kullanıcı değerlendirmeleri ve güvenlik önlemleriyle desteklenmiş olup, hem hizmet alan hem de hizmet veren taraflar için güvenilir ve kullanıcı dostu bir ortam sunar. '
                'Bu platform, toplumda dayanışma kültürünü güçlendirerek hem sosyal fayda sağlar hem de öğrencilere ek gelir imkânı sunar.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
