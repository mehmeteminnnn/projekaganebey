import 'package:flutter/material.dart';
import 'package:flutter_pin_code_fields/flutter_pin_code_fields.dart';
import 'package:projekaganebey/navbar.dart';

class SmsVerificationScreen extends StatelessWidget {
  final String phoneNumber;

  SmsVerificationScreen({required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SMS Doğrulaması',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blueAccent.shade100,
              Colors.blue.shade900,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Başlık ve Açıklama
              Text(
                'Doğrulama Gerekli',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Text(
                '$phoneNumber numarasına bir doğrulama kodu gönderildi.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 40),

              // Pin Kodu Girişi
              PinCodeFields(
                length: 6,
                fieldBorderStyle: FieldBorderStyle.square,
                responsive: true,
                fieldHeight: 50,
                fieldWidth: 40,
                borderWidth: 2.0,
                activeBorderColor: Colors.white,
                activeBackgroundColor: Colors.greenAccent,
                borderRadius: BorderRadius.circular(8),
                keyboardType: TextInputType.number,
                onComplete: (output) {
                  // Doğrulama Kodu Tamamlanınca Çalışacak
                  if (output == '123456') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Doğrulama başarılı')),
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MainScreen()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Geçersiz kod')),
                    );
                  }
                },
              ),
              SizedBox(height: 30),

              // Alt Bilgi
              Text(
                'Doğrulama kodunu almadınız mı? Kod gönderim süresi: 01:59',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Kod yeniden gönderme işlemi
                },
                child: Text(
                  'Tekrar Gönder',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
