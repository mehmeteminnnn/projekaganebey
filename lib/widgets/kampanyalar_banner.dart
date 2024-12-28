import 'package:flutter/material.dart';

class KampanyalarBanner extends StatelessWidget {
  const KampanyalarBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Kampanya resimlerinin listesi
    final List<String> kampanyaResimleri = [
      'assets/1.png',
      'assets/2.png',
      'assets/3.png',
    ];

    return SizedBox(
      height: 60, // Mevcut yükseklik korunuyor
      child: PageView.builder(
        scrollDirection: Axis.horizontal, // Yatay kaydırma
        itemCount: kampanyaResimleri.length, // Resim sayısı kadar oluştur
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Kampanya detaylarına yönlendirme
              debugPrint("Kampanya ${index + 1} tıklandı.");
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  kampanyaResimleri[index % kampanyaResimleri.length],
                  fit: BoxFit.cover, // Resimleri karta sığdırır
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
