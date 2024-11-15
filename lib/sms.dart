import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pin_code_fields/flutter_pin_code_fields.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:projekaganebey/navbar.dart';

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

  @override
  void initState() {
    super.initState();
    _verifyPhoneNumber();
  }

  // Firebase telefon numarası doğrulama
  Future<void> _verifyPhoneNumber() async {
    await _auth.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Otomatik doğrulama başarılıysa giriş yap
        await _auth.signInWithCredential(credential);
        _registerUser(); // Kullanıcıyı sisteme kaydet
      },
      verificationFailed: (FirebaseAuthException e) {
        Fluttertoast.showToast(msg: "Doğrulama başarısız: ${e.message}");
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
        });
      },
    );
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SMS Doğrulaması',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                '${widget.phoneNumber} numarasına bir doğrulama kodu gönderildi.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 40),

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
                  _verifyPhoneNumber(); // Yeni kod gönderme
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
