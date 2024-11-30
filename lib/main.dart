import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:projekaganebey/firebase_options.dart';
import 'package:projekaganebey/giris_ekrani.dart';

void main() async { 
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
      home: LoginScreen(),
    );
  }
}
