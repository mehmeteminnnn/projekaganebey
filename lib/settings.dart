import 'package:flutter/material.dart';

class AyarlarPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Ayarlar',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Şifremi değiştir'),
            onTap: () {
              // Şifre değiştirme işlemi
            },
          ),
          Divider(),
          ListTile(
            title: Text('Adreslerim'),
            onTap: () {
              // Adreslerim işlemi
            },
          ),
          Divider(),
          ListTile(
            title: Text('Fatura bilgilerim'),
            onTap: () {
              // Fatura bilgileri işlemi
            },
          ),
          Divider(),
          ListTile(
            title: Text('Hesabımı kapat'),
            onTap: () {
              // Hesap kapatma işlemi
            },
          ),
        ],
      ),
    );
  }
}
