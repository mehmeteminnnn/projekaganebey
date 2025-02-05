import 'package:Depot/yayinda_olmayan.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:Depot/ilanlar%C4%B1m.dart';
import 'package:Depot/screens/profilim_detay.dart';
import 'package:Depot/screens/settings.dart';
import 'package:Depot/screens/giris_ekrani.dart';
import 'package:Depot/services/firestore_services.dart';

class ProfileCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback? onTap;

  const ProfileCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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

class ProfileScreen extends StatefulWidget {
  final String? id;

  ProfileScreen({
    Key? key,
    this.id,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Profilim",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(7.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ProfileCard(
                    icon: Icons.visibility,
                    title: 'Yayında Olan İlanlar',
                    color: Colors.blue.shade50,
                    onTap: () {
                      //debugPrint("Yayında Olan İlanlar tıklandı");

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  IlanlarimPage(id: widget.id)));
                      debugPrint("İlanlarım tıklandı");

                      // Yayında olan ilanlar sayfasına yönlendirme yapılabilir
                    },
                  ),
                  ProfileCard(
                    icon: Icons.visibility_off,
                    title: 'Yayında Olmayan İlanlar',
                    color: Colors.blue.shade50,
                    onTap: () {
                      debugPrint("Yayında Olmayan İlanlar tıklandı");
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  OlmayanIlanlarimPage(id: widget.id)));
                      // Yayında olmayan ilanlar sayfasına yönlendirme yapılabilir
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            Column(
              children: [
                /*ListTile(
                  leading: const Icon(Icons.bookmarks, color: Colors.grey),
                  title: const Text('İlanlarım'),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                IlanlarimPage(id: widget.id)));
                    debugPrint("İlanlarım tıklandı");
                  },
                ),*/
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
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.grey),
                  title: const Text('Çıkış Yap'),
                  onTap: () {
                    // Çıkış yapma işlemi
                    _logout();
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundImage: AssetImage('assets/person.png'),
                    radius: 20,
                  ),
                  title: const Text(
                    'Profilim',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: FutureBuilder<String?>(
                    future: FirestoreService().getUserNameById(widget.id!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text('Yükleniyor...');
                      }
                      return Text(snapshot.data ?? 'İsim bulunamadı');
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ProfilDetayPage(userId: widget.id!)));
                    debugPrint("Profilim tıklandı");
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _logout() async {
    // Çıkış yapma işlemleri burada yapılabilir
    debugPrint("Çıkış yapıldı");

    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: LoginScreen(),
      withNavBar: false, // Alt menü gizlenir
      pageTransitionAnimation: PageTransitionAnimation.fade,
    );

    // Giriş ekranına dönüp diğer sayfaları temizlemek için
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }
}
