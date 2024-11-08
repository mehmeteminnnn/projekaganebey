import 'package:flutter/material.dart';

class FilterOpenPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filtreler'),
        leading: IconButton(
          icon: Icon(Icons.close),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Üreticiler',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.remove),
              ],
            ),
            SizedBox(height: 8),
            Text('Üretici seç', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: [
                  CheckboxListTile(
                    title: Text('Yıldız Entegre'),
                    value: false,
                    onChanged: (bool? value) {},
                  ),
                  CheckboxListTile(
                    title: Text('Kastamonu Entegre'),
                    value: false,
                    onChanged: (bool? value) {},
                  ),
                  // Diğer üreticiler için CheckboxListTile widgetları ekle
                ],
              ),
            ),
            Divider(),
            ListTile(
              title: Text('Boyut'),
              trailing: Icon(Icons.add),
            ),
            Divider(),
            ListTile(
              title: Text('Fiyat'),
              trailing: Icon(Icons.add),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.view_list), label: 'İlanlar'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Bildirim'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'İlan ver'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'İlanlarım'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
