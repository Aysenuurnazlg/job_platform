import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_platform/loginscreen.dart';

void main() {
  testWidgets('LoginScreen widget test', (WidgetTester tester) async {
    // LoginScreen widget'ını oluştur
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    // Başlık kontrolü
    expect(find.text('Giriş Yap'), findsOneWidget);

    // Form alanlarının varlığını kontrol et
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('E-posta'), findsOneWidget);
    expect(find.text('Şifre'), findsOneWidget);

    // Giriş Yap butonunun varlığını kontrol et
    expect(find.text('Giriş Yap'), findsOneWidget);
  });
}
