import 'package:flutter/material.dart';
import 'package:Depot/screens/giris_ekrani.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Firebase Messaging ile abone olma
    FirebaseMessaging.instance.subscribeToTopic('all').then((_) {
      print("Cihaz 'all' topic'ine abone oldu.");
    });

    // Splash ekranını birkaç saniye gösterdikten sonra Login ekranına geçiş
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Arkaplan rengi
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo veya animasyon
            Image.asset('assets/daire.png', width: 100, height: 100),
            SizedBox(height: 20),
            // Yükleme göstergesi
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            SizedBox(height: 20),
            // Uygulama ismi veya mesaj
            Text(
              'Yükleniyor...',
              style: TextStyle(color: Colors.blue, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
