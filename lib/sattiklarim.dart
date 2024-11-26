import 'package:flutter/material.dart';

class SattiklarimPage extends StatelessWidget {
  final List<Map<String, String>> products = [
    {'name': 'Kastamonu Entegre', 'price': '1.345 TL'},
    {'name': 'Yıldız Entegre', 'price': '15.045 TL'},
    {'name': 'Teverpan', 'price': '6.345 TL'},
    {'name': 'Çamsan Poyraz', 'price': '7.345 TL'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Sattıklarım',
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
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3 / 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Card(
              elevation: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Image.network(
                      width: double.infinity,
                      'https://ideacdn.net/idea/ar/16/myassets/products/353/pr_01_353.jpg?revision=1697143329', // Ürün resmi
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['name']!,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          product['price']!,
                          style: TextStyle(color: Colors.orange),
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
