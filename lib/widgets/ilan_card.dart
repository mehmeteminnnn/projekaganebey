import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projekaganebey/functions/favori.dart';
import 'package:projekaganebey/ilan_detay.dart';

Widget buildIlanCard({
  bool? kendiIlanim,
  String? userId,
  String? baslik,
  double? fiyat,
  String? resimUrl,
  required String ilanID,
  required BuildContext context,
}) {
  return GestureDetector(
    onTap: () {
      debugPrint("ilanID: $ilanID, userId: $userId");
      // İlan detay sayfasına yönlendirme
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IlanDetayPage(
            id: userId,
            ilanId: ilanID,
            ilanbaslik: baslik,
            kendiIlanim: kendiIlanim ?? false,
          ),
        ),
      );
    },
    child: Card(
      color: Colors.white,
      child: Stack(
        children: [
          Column(
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
          if (kendiIlanim != true)
            Positioned(
              top: 0,
              right: 0,
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  // Verinin olup olmadığını ve documentin var olup olmadığını kontrol ediyoruz
                  if (snapshot.hasData &&
                      snapshot.data != null &&
                      snapshot.data!.exists) {
                    // favorilerim alanı varsa, yoksa boş bir liste ile başlatıyoruz
                    List<dynamic> favorilerim =
                        snapshot.data!['favorilerim'] ?? [];

                    // favorilerim içinde ilanID var mı diye kontrol ediyoruz
                    bool isFavori = favorilerim.contains(ilanID);

                    // Favori durumu ile ilgili işlemleri burada yapabilirsiniz
                    return IconButton(
                      icon: Icon(
                        isFavori ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        if (userId != null) {
                          toggleFavori(userId: userId, ilanID: ilanID);
                        } else {
                          debugPrint("User ID null, favorilere eklenemedi.");
                        }
                      },
                    );
                  } else {
                    // Eğer veri yoksa ya da document bulunmazsa favori butonu burada görüntüleniyor
                    return IconButton(
                      icon:
                          const Icon(Icons.favorite_border, color: Colors.red),
                      onPressed: () {
                        if (userId != null) {
                          toggleFavori(userId: userId, ilanID: ilanID);
                        } else {
                          debugPrint("User ID null, favorilere eklenemedi.");
                        }
                      },
                    );
                  }
                },
              ),
            ),
        ],
      ),
    ),
  );
}
