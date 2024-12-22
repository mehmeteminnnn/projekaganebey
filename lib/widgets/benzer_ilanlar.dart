import 'package:flutter/material.dart';
import 'package:projekaganebey/ilan_detay.dart';
import 'package:projekaganebey/models/ilan.dart';
import 'package:projekaganebey/services/firestore_services.dart';

Widget benzerIlanlarWidget(String ilanId, String kullaniciId) {
  final FirestoreService _firestoreService = FirestoreService();

  return FutureBuilder<List<IlanModel>>(
    future: _firestoreService.fetchSimilarIlanlar(ilanId),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text('Hata: ${snapshot.error}'));
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return const Center(child: Text('Benzer ilan bulunamadı.'));
      }

      final ilanlar = snapshot.data!;
      return SizedBox(
        height: 200, // Kartların yüksekliğini ayarlayın
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: ilanlar.length,
          itemBuilder: (context, index) {
            final ilan = ilanlar[index];
            return Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IlanDetayPage(
                          id: kullaniciId,
                          ilanId: ilan.id!,
                          ilanbaslik: ilan.baslik,
                        ),
                      ));
                },
                child: Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    width: 150, // Kart genişliği
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            ilan.resimler?[0] ?? '', // İlan resmi
                            height: 100,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 100,
                                color: Colors.grey.shade300,
                                child: const Center(
                                  child: Icon(Icons.image),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ilan.baslik ?? 'Başlık Yok', // İlan başlığı
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${ilan.fiyat ?? 'Fiyat Yok'} TL', // İlan fiyatı
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    },
  );
}
