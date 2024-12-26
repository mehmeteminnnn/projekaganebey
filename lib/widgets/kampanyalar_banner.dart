import 'package:flutter/material.dart';

class KampanyalarBanner extends StatelessWidget {
  const KampanyalarBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60, // Banner yüksekliği
      child: PageView.builder(
        scrollDirection: Axis.horizontal, // Yatay kaydırma
        itemCount: 5, // Kampanya sayısı
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Kampanya detaylarına yönlendirme
              debugPrint("Kampanya $index tıklandı.");
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              width: 400,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.blue.shade100,
              ),
              child: Center(
                child: Text(
                  "Kampanya ${index + 1}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
