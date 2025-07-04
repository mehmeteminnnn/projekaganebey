import 'dart:async'; // Timer için gerekli
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pin_code_fields/flutter_pin_code_fields.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:Depot/navbar.dart';

class SmsVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String name;
  final String email;
  final String password;

  SmsVerificationScreen(
      {required this.phoneNumber,
      required this.name,
      required this.email,
      required this.password});

  @override
  State<SmsVerificationScreen> createState() => _SmsVerificationScreenState();
}

class _SmsVerificationScreenState extends State<SmsVerificationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _verificationId = '';
  final TextEditingController _smsController = TextEditingController();
  int _countdown = 120; // 2 dakika geri sayım
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _startCountdown(); // Geri sayımı başlat
  }

  // Geri sayım başlatma
  void _startCountdown() {
    debugPrint(widget.phoneNumber);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        _timer?.cancel(); // Geri sayım tamamlandığında timer'ı durdur
      }
    });
  }

  // Firebase telefon numarası doğrulama
  Future<void> _verifyPhoneNumber() async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint("Otomatik doğrulama başarılı");
          await _auth.signInWithCredential(credential);
          _registerUser(); // Kullanıcıyı sisteme kaydet
        },
        verificationFailed: (FirebaseAuthException e) {
          Fluttertoast.showToast(
              msg: "Doğrulama başarısız: ${e.message}, Hata Kodu: ${e.code}");
          print("Hata Kodu: ${e.code}, Hata Mesajı: ${e.message}");
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
          });
          Fluttertoast.showToast(msg: "Doğrulama kodu gönderildi.");
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _verificationId = verificationId;
          });
        },
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "Hata: ${e.toString()}");
    }
  }

  // SMS doğrulama kodu ile giriş
  Future<void> _signInWithPhoneNumber() async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _smsController.text,
      );

      await _auth.signInWithCredential(credential);
      _registerUser(); // Kullanıcıyı sisteme kaydet
    } catch (e) {
      Fluttertoast.showToast(msg: "Doğrulama hatası: $e");
    }
  }

  // Kullanıcıyı Firestore'a kaydetme işlemi
  Future<void> _registerUser() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': widget.name,
          'password': widget
              .password, // Şifreyi kaydetmek genellikle güvenlik için önerilmez.
          'phone': widget.phoneNumber,
          'uid': user.uid,
          "email": widget.email,
          'createdAt': Timestamp.now(),
        });

        Fluttertoast.showToast(msg: "Kayıt başarılı!");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      } catch (e) {
        Fluttertoast.showToast(msg: "Kayıt sırasında hata oluştu: $e");
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Timer'ı durdur
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SMS Doğrulaması',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
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
              const Text(
                'Doğrulama Gerekli',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${widget.phoneNumber} numarasına bir doğrulama kodu gönderildi.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 40),

              // Pin Kodu Girişi
              PinCodeFields(
                controller: _smsController,
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
                  if (output.isNotEmpty) {
                    _signInWithPhoneNumber(); // Kod doğrulandıysa işlemi başlat
                  }
                },
              ),
              const SizedBox(height: 30),

              // Alt Bilgi
              Text(
                'Doğrulama kodunu almadınız mı? Kod gönderim süresi: ${_countdown ~/ 60}:${(_countdown % 60).toString().padLeft(2, '0')}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Kod yeniden gönderme işlemi
                  _verifyPhoneNumber(); // Yeni kod gönderme
                },
                child: const Text(
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
