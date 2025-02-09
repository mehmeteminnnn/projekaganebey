import 'package:flutter/material.dart';
import 'package:Depot/screens/admin%20panel/banners.dart';
import 'package:Depot/screens/admin%20panel/notification_screen.dart';
import 'package:Depot/services/firestore_services.dart';
import 'package:Depot/screens/giris_ekrani.dart';
import 'package:Depot/navbar.dart';
import 'package:Depot/styles.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final FirestoreService _firestoreService = FirestoreService();
  int totalUsers = 0;
  int totalAds = 0;

  // Kullanıcı adı ve şifre için değişkenler
  String username = ""; // Varsayılan kullanıcı adı
  String password = ""; // Varsayılan şifre

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCounts();
    _loadAdminInfo(); // Admin bilgilerini yükle
  }

  Future<void> _loadCounts() async {
    totalUsers = await _firestoreService.getTotalUsers();
    totalAds = await _firestoreService.getTotalAds();
    setState(() {});
  }

  Future<void> _loadAdminInfo() async {
    var adminInfo = await _firestoreService.getAdminInfo();
    setState(() {
      username = adminInfo['username'];
      password = adminInfo['password'];
      _usernameController.text = username; // TextField için varsayılan değer
    });
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _updateAdminInfo() async {
    String newUsername = _usernameController.text;
    String newPassword = _passwordController.text;

    // Eğer şifre boşsa, sadece kullanıcı adını güncelle
    if (newPassword.isEmpty) {
      await _firestoreService.updateAdminInfo(
          newUsername, password); // Eski şifreyi kullan
    } else {
      await _firestoreService.updateAdminInfo(newUsername, newPassword);
    }

    setState(() {
      username = newUsername;
      password = newPassword.isEmpty
          ? password
          : newPassword; // Şifre boşsa eski şifreyi koru
    });

    // Başarılı güncelleme mesajı gösterebilirsiniz
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Admin bilgileri güncellendi.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          "Admin Panel",
          style: appBarTextStyle,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: _logout,
            tooltip: "Çıkış Yap",
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildSmallStatCard(
                        "Toplam Kullanıcı",
                        totalUsers.toString(),
                        Icons.people,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSmallStatCard(
                        "Toplam İlan",
                        totalAds.toString(),
                        Icons.article,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildManagementCard(
                  "Banner Yönetimi",
                  Icons.image,
                  Colors.purple,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BannerPage()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildManagementCard(
                  "Bildirim Yönetimi",
                  Icons.notifications_active,
                  Colors.orange,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NotificationPage()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildManagementCard(
                  "Admin Bilgileri",
                  Icons.admin_panel_settings,
                  Colors.blueAccent,
                  () {
                    // Admin bilgilerini güncelleme işlemi
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Admin Bilgilerini Güncelle"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: _usernameController,
                                decoration:
                                    const InputDecoration(labelText: "Kullanıcı Adı"),
                              ),
                              TextField(
                                controller: _passwordController,
                                decoration: const InputDecoration(labelText: "Şifre"),
                                obscureText: true,
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                _updateAdminInfo();
                                Navigator.of(context).pop();
                              },
                              child: const Text("Güncelle"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("İptal"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmallStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildManagementCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
