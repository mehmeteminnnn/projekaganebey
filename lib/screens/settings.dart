import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Depot/adreslerim.dart';

class AyarlarPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Ayarlar',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        /* flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),*/
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSettingsCard(
              context,
              title: 'Şifremi değiştir',
              icon: Icons.lock,
              iconColor: Colors.blue,
              onTap: () {
                _showPasswordChangeDialog(context);
              },
            ),
            _buildSettingsCard(
              context,
              title: 'Adreslerim',
              icon: Icons.location_on,
              iconColor: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdreslerimPage()),
                );
              },
            ),
            _buildSettingsCard(
              context,
              title: 'Hesabımı kapat',
              icon: Icons.delete_forever,
              iconColor: Colors.redAccent,
              onTap: () {
                _showDeleteAccountDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        leading: Icon(
          icon,
          size: 32,
          color: iconColor ?? Theme.of(context).primaryColor,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  void _showPasswordChangeDialog(BuildContext context) {
    final TextEditingController oldPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Şifremi Değiştir'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mevcut Şifre',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Yeni Şifre',
                  border: OutlineInputBorder(),
                ),
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
              onPressed: () async {
                String oldPassword = oldPasswordController.text.trim();
                String newPassword = newPasswordController.text.trim();

                if (oldPassword.isEmpty || newPassword.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tüm alanları doldurun.')),
                  );
                  return;
                }

                try {
                  User? user = auth.currentUser;

                  if (user != null) {
                    String uid = user.uid;

                    // Firestore'dan mevcut şifreyi getir
                    DocumentSnapshot snapshot =
                        await firestore.collection('users').doc(uid).get();

                    if (snapshot.exists) {
                      String currentPassword =
                          snapshot.get('password'); // Mevcut şifre
                      debugPrint('currentPassword: $currentPassword');

                      if (currentPassword == oldPassword) {
                        // Şifre doğru, yeni şifreyi güncelle
                        await firestore.collection('users').doc(uid).update({
                          'password': newPassword,
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Şifre başarıyla güncellendi.')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Mevcut şifre yanlış.')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kullanıcı bulunamadı.')),
                      );
                    }
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Hata: ${e.toString()}')),
                  );
                }

                Navigator.pop(context);
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }
}

void _showDeleteAccountDialog(BuildContext context) {
  final FirebaseAuth auth = FirebaseAuth.instance;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Hesabımı Kapat'),
        content: const Text('Hesabınızı silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                User? user = auth.currentUser;

                if (user != null) {
                  await user.delete();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Hesabınız başarıyla silindi.')),
                  );
                  Navigator.pop(context);
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Hata: ${e.toString()}')),
                );
              }
            },
            child: const Text('Sil'),
          ),
        ],
      );
    },
  );
}

class FaturaBilgilerimPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fatura Bilgilerim'),
      ),
      body: const Center(
        child: Text(
          'Fatura bilgilerim ekranı burada olacak.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
