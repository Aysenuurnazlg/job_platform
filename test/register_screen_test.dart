import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_platform/register_screen.dart';

void main() {
  testWidgets('RegisterScreen widget test', (WidgetTester tester) async {
    // RegisterScreen widget'ını oluştur
    await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

    // Başlık kontrolü
    expect(find.text('Kayıt Ol'), findsOneWidget);

    // Form alanlarının varlığını kontrol et
    expect(find.byType(TextFormField), findsNWidgets(4));
    expect(find.text('Ad Soyad'), findsOneWidget);
    expect(find.text('E-posta'), findsOneWidget);
    expect(find.text('Telefon Numarası'), findsOneWidget);
    expect(find.text('Şifre'), findsOneWidget);

    // Kayıt Ol butonunun varlığını kontrol et
    expect(find.text('Kayıt Ol'), findsNWidgets(2)); // AppBar ve buton
  });
}
