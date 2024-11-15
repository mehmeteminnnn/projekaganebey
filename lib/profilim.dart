import 'package:flutter/material.dart';
import 'package:projekaganebey/profilim/bilgileri_duzenle.dart';
import 'package:projekaganebey/profilim/hesap_ayarlari.dart';
import 'package:projekaganebey/profilim/sifre_degistir.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profilim'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Ayarlar sayfasına yönlendirme
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.blue),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profil Resmi ve Adı
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage(
                            'assets/profile_placeholder.png'), // Profil resmi
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Mehmet Emin Tok',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'mehmet.emin@ornek.com',
                        style: TextStyle(fontSize: 18, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),

                // Bilgileri düzenleme butonları
                ProfileListItem(
                  icon: Icons.edit,
                  title: 'Bilgileri Düzenle',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditInfoScreen()),
                    );
                    // Bilgileri düzenleme ekranına yönlendirme
                  },
                ),
                ProfileListItem(
                  icon: Icons.lock,
                  title: 'Şifre Değiştir',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChangePasswordScreen()),
                    );
                    // Şifre değiştirme ekranına yönlendirme
                  },
                ),
                ProfileListItem(
                  icon: Icons.settings,
                  title: 'Hesap Ayarları',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AccountSettingsScreen()),
                    );
                    // Hesap ayarlarına yönlendirme
                  },
                ),
                ProfileListItem(
                  icon: Icons.exit_to_app,
                  title: 'Çıkış Yap',
                  color: Colors.red,
                  onTap: () {
                    // Çıkış işlemi yapılacak
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileListItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const ProfileListItem(
      {required this.icon,
      required this.title,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        margin: EdgeInsets.symmetric(vertical: 10),
        elevation: 5,
        child: ListTile(
          leading: Icon(icon, color: color),
          title: Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
      ),
    );
  }
}
