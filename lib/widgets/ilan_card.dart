import 'package:flutter/material.dart';
import 'package:projekaganebey/ilan_detay.dart';

Widget buildIlanCard(
    {String? userId,
    String? baslik,
    double? fiyat,
    String? resimUrl,
    required ilanID,
    context}) {
  return GestureDetector(
    onTap: () {
      debugPrint("ilanID: $ilanID,userıd: $userId");
      // İlan detay sayfasına yönlendirme
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IlanDetayPage(
            id: userId,
            ilanId: ilanID,
            ilanbaslik: baslik,
          ),
        ),
      );
    },
    child: Card(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Image.network(
              resimUrl ??
                  'https://ideacdn.net/idea/ar/16/myassets/products/353/pr_01_353.jpg?revision=1697143329',
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  baslik?.isNotEmpty == true ? baslik! : 'Başlık yok',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fiyat: ${fiyat?.toStringAsFixed(2)} TL',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
