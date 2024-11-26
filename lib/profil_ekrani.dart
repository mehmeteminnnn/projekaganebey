import 'package:flutter/material.dart';
import 'package:projekaganebey/banka_hesap.dart';
import 'package:projekaganebey/profilim_detay.dart';
import 'package:projekaganebey/sattiklarim.dart';
import 'package:projekaganebey/settings.dart';

class ProfileCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback? onTap; // Tıklanabilirlik için eklenen özellik

  const ProfileCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.color,
    this.onTap, // Tıklanma işlemi için parametre
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Tıklanma işlemi burada
      child: Container(
        width: MediaQuery.of(context).size.width * 0.44,
        padding: const EdgeInsets.all(20.0),
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
      ),
    );
  }
}

class BankInfoCard extends StatelessWidget {
  final VoidCallback? onTap; // Tıklanabilirlik için eklenen özellik

  const BankInfoCard({Key? key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Tıklanma işlemi burada
      child: Container(
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
      ),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ProfileCard(
                  icon: Icons.shopping_cart,
                  title: 'Aldıklarım',
                  color: Colors.blue.shade50,
                  onTap: () {
                    // Tıklama olayı
                    debugPrint("Aldıklarım tıklandı");
                  },
                ),
                ProfileCard(
                  icon: Icons.local_offer,
                  title: 'Sattıklarım',
                  color: Colors.blue.shade50,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SattiklarimPage()));
                    debugPrint("Sattıklarım tıklandı");
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: BankInfoCard(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BankaHesapBilgileriPage()));
                debugPrint("Banka hesap bilgileri tıklandı");
              },
            ),
          ),
          const Spacer(),
          Column(
            children: [
              ListTile(
                leading: const Icon(Icons.settings, color: Colors.grey),
                title: const Text('Ayarlar'),
                subtitle: const Text('Gizlilik ve çıkış'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AyarlarPage()));
                  debugPrint("Ayarlar tıklandı");
                },
              ),
              ListTile(
                leading: const Icon(Icons.help_outline, color: Colors.grey),
                title: const Text('Yardım ve Destek'),
                subtitle: const Text(
                    'Yardım merkezi, Şartlar ve koşullar, Gizlilik politikası'),
                onTap: () {
                  debugPrint("Yardım ve Destek tıklandı");
                },
              ),
              const Divider(),
              ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      AssetImage('assets/person.png'), // Profil resmi
                  radius: 20,
                ),
                title: const Text('Profilim',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    )),
                subtitle: const Text('Mehmet Emin Tok'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfilDetayPage()));
                  debugPrint("Profilim tıklandı");
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
