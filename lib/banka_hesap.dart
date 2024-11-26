import 'package:flutter/material.dart';

class BankaHesapBilgileriPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Banka hesap bilgileri',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Fatura adresi'),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(labelText: 'Şehir'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(labelText: 'İlçe'),
                  ),
                ),
              ],
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Mahalle'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'T.C Kimlik No.'),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration:
                        InputDecoration(labelText: 'IBAN sahibinin adı'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration:
                        InputDecoration(labelText: 'IBAN sahibinin soyadı'),
                  ),
                ),
              ],
            ),
            TextField(
              decoration: InputDecoration(labelText: 'IBAN No.'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Kaydet işlemi
              },
              child: Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}
