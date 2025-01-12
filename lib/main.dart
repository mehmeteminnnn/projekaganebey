import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:projekaganebey/firebase_options.dart';
import 'package:projekaganebey/services/notification_services.dart';
import 'package:projekaganebey/screens/splash_screen.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Arka planda bildirim geldi: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // NotificationService başlatılıyor
  await NotificationService().initialize();

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Kullanıcıdan bildirim izni al
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  print('Bildirim izni durumu: ${settings.authorizationStatus}');

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Ön planda bildirim geldi: ${message.notification?.title}');
    NotificationService().showNotification(message); // Bildirimi göster
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler); 
  

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: AppBarTheme(backgroundColor: Colors.white)),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
