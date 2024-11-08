import 'package:flutter/material.dart';

class Ilan {
  final String title;
  final String detail;
  final String category;
  final double price;
  final String imageUrl;

  Ilan({
    required this.title,
    required this.detail,
    required this.category,
    required this.price,
    required this.imageUrl,
  });
}

class IlanListScreen extends StatelessWidget {
  final List<Ilan> ilanlar = [
    Ilan(
        title: 'Konut İlanı',
        detail: 'Geniş ve ferah daire.',
        category: 'Konut',
        price: 250000,
        imageUrl:
            'https://www.genclikcopy.com/wp-content/uploads/2021/05/maket-kartonu-kraft-600x400.jpg'),
    Ilan(
        title: 'Ofis İlanı',
        detail: 'Merkezi konumda ofis.',
        category: 'Ofis',
        price: 150000,
        imageUrl:
            'https://www.genclikcopy.com/wp-content/uploads/2021/05/maket-kartonu-kraft-600x400.jpg'),
    Ilan(
        title: 'Mağaza İlanı',
        detail: 'Alışveriş merkezinde mağaza.',
        category: 'Mağaza',
        price: 300000,
        imageUrl:
            'https://www.genclikcopy.com/wp-content/uploads/2021/05/maket-kartonu-kraft-600x400.jpg'),
    Ilan(
        title: 'Endüstriyel İlan',
        detail: 'Fabrika alanı.',
        category: 'Endüstriyel',
        price: 500000,
        imageUrl:
            'https://www.genclikcopy.com/wp-content/uploads/2021/05/maket-kartonu-kraft-600x400.jpg'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('İlanlarım'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: ilanlar.length,
          itemBuilder: (context, index) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  // İlan Görseli
                  ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      ilanlar[index].imageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // İlan Başlığı
                        Text(
                          ilanlar[index].title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        SizedBox(height: 10),

                        // İlan Detayı
                        Text(
                          ilanlar[index].detail,
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                        SizedBox(height: 10),

                        // Kategori ve Fiyat Bilgisi
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Kategori: ${ilanlar[index].category}',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            Text(
                              'Fiyat: ${ilanlar[index].price.toStringAsFixed(0)} TL',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: IlanListScreen(),
  ));
}
