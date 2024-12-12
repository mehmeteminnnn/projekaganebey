import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Tarih formatlama için

class ProfilDetayPage extends StatefulWidget {
  final String userId;

  const ProfilDetayPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<ProfilDetayPage> createState() => _ProfilDetayPageState();
}

class _ProfilDetayPageState extends State<ProfilDetayPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Profilim",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              !snapshot.data!.exists) {
            return const Center(
                child: Text("Kullanıcı bilgileri yüklenemedi."));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;

          // createdAt alanını DateTime'a çevir
          DateTime? createdAt = userData['createdAt'] != null
              ? (userData['createdAt'] as Timestamp).toDate()
              : null;
          String formatDate(DateTime date) {
            List<String> months = [
              'Ocak',
              'Şubat',
              'Mart',
              'Nisan',
              'Mayıs',
              'Haziran',
              'Temmuz',
              'Ağustos',
              'Eylül',
              'Ekim',
              'Kasım',
              'Aralık'
            ];

            int day = date.day;
            String month = months[date.month - 1];
            int year = date.year;

            return "$day $month $year";
          }

          String membershipInfo = createdAt != null
              ? "📅 ${formatDate(createdAt)} tarihinden beri üye"
              : "Üyelik tarihi bilinmiyor";

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage:
                          AssetImage('assets/person.png'), // Profil fotoğrafı
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userData['name'] ?? 'İsim Yok',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(membershipInfo),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                Text('İsim',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(userData['name'] ?? 'İsim Yok'),
                const Divider(),
                Text('Telefon Numarası',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(userData['phone'] ?? 'Telefon Yok'),
                const Divider(),
                Text('E-Posta',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(userData['email'] ?? 'E-Posta Yok'),
                const Spacer(),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _openEditProfileDialog(context, userData);
                    },
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text('Profili Düzenle',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Çıkış işlemleri
                    },
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text('Hesabımdan Çıkış Yap',
                        style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openEditProfileDialog(
      BuildContext context, Map<String, dynamic> userData) {
    final nameController = TextEditingController(text: userData['name']);
    final phoneController = TextEditingController(text: userData['phone']);
    final emailController = TextEditingController(text: userData['email']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Profili Düzenle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'İsim'),
              ),
              TextField(
                controller: phoneController,
                decoration:
                    const InputDecoration(labelText: 'Telefon Numarası'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'E-Posta'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.userId)
                    .update({
                  'name': nameController.text,
                  'phone': phoneController.text,
                  'email': emailController.text,
                }).then((value) {
                  Navigator.pop(context);
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Hata: $error')),
                  );
                });
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }
}
