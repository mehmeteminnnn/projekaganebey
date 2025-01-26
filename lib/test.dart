import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SmsVerificationScreen2 extends StatefulWidget {
  @override
  _SmsVerificationScreenState createState() => _SmsVerificationScreenState();
}

class _SmsVerificationScreenState extends State<SmsVerificationScreen2> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _verificationId = '';
  final TextEditingController _smsController = TextEditingController();

  // Sabit telefon numarasına SMS gönderme fonksiyonu
  Future<void> _sendSmsCode() async {
    String phoneNumber = '+905342119155'; // Sabit telefon numarası

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          Fluttertoast.showToast(msg: 'Doğrulama başarılı');
        },
        verificationFailed: (FirebaseAuthException e) {
          Fluttertoast.showToast(msg: 'Doğrulama başarısız: ${e.message}');
          debugPrint('Doğrulama başarısız: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
          });
          Fluttertoast.showToast(msg: 'Doğrulama kodu gönderildi!');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _verificationId = verificationId;
          });
        },
      );
    } catch (e) {
      Fluttertoast.showToast(msg: 'Hata: $e');
    }
  }

  // SMS kodunu doğrulama
  Future<void> _submitVerificationCode() async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _smsController.text,
      );
      await _auth.signInWithCredential(credential);
      Fluttertoast.showToast(msg: 'Doğrulama başarılı');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Doğrulama hatası: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SMS Doğrulama')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                'Telefon numarasına doğrulama kodu göndermek için butona tıklayın.'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendSmsCode,
              child: Text('SMS Gönder'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _smsController,
              decoration: InputDecoration(
                labelText: 'Doğrulama Kodu',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitVerificationCode,
              child: Text('Doğrula'),
            ),
          ],
        ),
      ),
    );
  }
}
