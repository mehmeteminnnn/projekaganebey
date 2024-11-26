import 'package:flutter/material.dart';

class ProfilDetayPage extends StatelessWidget {
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
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
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kağan A.',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text('İstanbul, Küçükçekmece'),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('📅 Kas 2024 tarihinden beri üye'),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 20),
                        SizedBox(width: 8),
                        Icon(Icons.email, size: 20),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Text('İsim', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Kağan A.'),
            Divider(),
            Text('Telefon numarası',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('0501 110 1101'),
            Divider(),
            Text('E-Posta', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('kagan@gmail.com'),
            Spacer(),
            // Profili düzenle butonunu ortalamak
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Profil düzenle buton işlemi
                },
                child: Text('Profili düzenle'),
              ),
            ),
            SizedBox(height: 16),
            // Hesabımdan çıkış yap butonunu ortalamak
            Center(
              child: OutlinedButton(
                onPressed: () {
                  // Çıkış yapma işlemi
                },
                child: Text('Hesabımdan çıkış yap'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
