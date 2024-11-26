import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Profilim",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            )),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // İlk satırdaki kartlar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ProfileCard(
                  icon: Icons.shopping_cart,
                  title: 'Aldıklarım',
                  color: Colors.blue.shade50,
                ),
                ProfileCard(
                  icon: Icons.local_offer,
                  title: 'Sattıklarım',
                  color: Colors.blue.shade50,
                ),
              ],
            ),
          ),
          // Banka Hesap Bilgileri Kartı
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: BankInfoCard(),
          ),
          const Spacer(),
          // Alt Menü
          Column(
            children: [
              ListTile(
                leading: const Icon(Icons.settings, color: Colors.grey),
                title: const Text('Ayarlar'),
                subtitle: const Text('Gizlilik ve çıkış'),
              ),
              ListTile(
                leading: const Icon(Icons.help_outline, color: Colors.grey),
                title: const Text('Yardım ve Destek'),
                subtitle: const Text(
                    'Yardım merkezi, Şartlar ve koşullar, Gizlilik politikası'),
              ),
              const Divider(),
              // Profilim kısmı
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage(
                      'assets/person.png'), // Kendi profil resminizi ekleyebilirsiniz
                  radius: 20,
                ),
                title: const Text('Profilim',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    )),
                subtitle: const Text('Mehmet Emin Tok'),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const ProfileCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.44, // Daha geniş
      padding: const EdgeInsets.all(20.0), // Daha büyük padding
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(icon, color: Colors.black),
          ),
          const SizedBox(height: 10.0),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class BankInfoCard extends StatelessWidget {
  const BankInfoCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.credit_card, color: Colors.white),
          SizedBox(height: 8.0),
          Text(
            'Banka hesap bilgileri',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Banka kartı ekle',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }
}
