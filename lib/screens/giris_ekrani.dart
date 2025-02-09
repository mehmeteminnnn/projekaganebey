import 'package:firebase_auth/firebase_auth.dart';
import 'package:Depot/screens/kayit_ol.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:Depot/navbar.dart';
import 'package:Depot/screens/admin%20panel/admin_panel.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:Depot/test.dart';
import 'package:Depot/screens/search_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Kullanıcı giriş işlemini kontrol eden fonksiyon
  Future<void> _loginUser() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(), // Yükleme animasyonu
        );
      },
    );

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // Eğer admin bilgileri ile giriş yapılıyorsa
      final QuerySnapshot adminSnapshot = await FirebaseFirestore.instance
          .collection('admin')
          .where('username', isEqualTo: email)
          .where('password', isEqualTo: password)
          .get();

      if (adminSnapshot.docs.isNotEmpty) {
        Navigator.pop(context); // Yükleme göstergesini kapat
        Fluttertoast.showToast(msg: "Admin olarak giriş yapıldı!");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardPage()),
        );
        return;
      }

      final QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .get();

      Navigator.pop(context); // Yükleme göstergesini kapat

      if (userSnapshot.docs.isNotEmpty) {
        final id = userSnapshot.docs.first.id;

        // Firebase token alalım
        String? token = await _firebaseMessaging.getToken();

        if (token != null) {
          // Token zaten Firestore'da var mı kontrol edelim
          final tokenSnapshot = await FirebaseFirestore.instance
              .collection('user_tokens')
              .doc(id)
              .get();

          if (!tokenSnapshot.exists ||
              tokenSnapshot.data()?['token'] != token) {
            // Token mevcut değilse, ekleyelim
            await FirebaseFirestore.instance
                .collection('user_tokens')
                .doc(id)
                .set({
              'token': token,
            });
            print("Yeni token Firestore'a kaydedildi");
          }
        }

        Fluttertoast.showToast(msg: "Giriş başarılı!");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen(id: id)),
        );
      } else {
        Fluttertoast.showToast(msg: "E-posta veya şifre hatalı.");
      }
    } catch (e) {
      Navigator.pop(context); // Hata durumunda da yükleme göstergesini kapat
      Fluttertoast.showToast(msg: "Hata: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/daire.png', width: 100),
            const SizedBox(height: 40),

            // E-posta alanı
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'E-posta',
                labelStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.email, color: Colors.blueAccent),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),

            // Şifre alanı
            TextField(
              controller: _passwordController,
              obscureText: _obscureText,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
                labelText: 'Şifre',
                labelStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.lock, color: Colors.blueAccent),
              ),
            ),
            const SizedBox(height: 20),

            // Giriş butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loginUser, // Giriş işlemini başlatır
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  'Giriş Yap',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Kayıt ol bağlantısı
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              child: const Text(
                'Hesabınız yok mu? Kayıt olun',
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
