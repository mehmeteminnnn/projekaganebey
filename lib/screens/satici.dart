import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projekaganebey/services/user_services.dart';
import 'package:projekaganebey/widgets/ilan_card.dart';

class SellerPage extends StatelessWidget {
  final Map<String, dynamic> sellerData;

  const SellerPage({Key? key, required this.sellerData}) : super(key: key);

  Future<List<Map<String, dynamic>>> _getListings(
      List<dynamic> listingIds) async {
    final List<Map<String, dynamic>> listings = [];
    for (var listingId in listingIds) {
      var doc = await FirebaseFirestore.instance
          .collection('ilanlar')
          .doc(listingId)
          .get();
      if (doc.exists) {
        listings.add(doc.data() as Map<String, dynamic>);
      }
    }
    return listings;
  }

  @override
  Widget build(BuildContext context) {
    final sellerPhoto =
        sellerData['photo'] ?? ''; // Eğer null ise boş bir string atanır.
    final List<dynamic> listingIds =
        sellerData['ilanlar'] ?? []; // İlan ID'leri.

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Satıcı Bilgileri",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        actions: [
          // Popup menu button
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "report") {
                // Şikayet ekranına gitme veya şikayet işlemi
                _showReportDialog(context);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: "report",
                  child: Text("Satıcıyı Şikayet Et"),
                ),
              ];
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Satıcı Bilgileri Kısmı
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 35, //Daha küçük bir avatar
                  backgroundImage: (sellerPhoto.isNotEmpty
                      ? NetworkImage(sellerPhoto)
                      : null),
                  child: sellerPhoto.isEmpty
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  // Metni sarmak için Expanded ekledik
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sellerData['name'] ?? 'Bilinmeyen Satıcı',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        overflow: TextOverflow
                            .ellipsis, // Uzun metinler için kesme ekleyin
                        maxLines: 1, // Bir satırda tutun
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            Icons.star,
                            color: index < (sellerData['rating'] ?? 0)
                                ? Colors.orange
                                : Colors.grey,
                            size: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Puan: ${(sellerData['rating'] ?? 0)}/5",
                        style:
                            const TextStyle(fontSize: 14, color: Colors.orange),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 35),

                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inventory, size: 25, color: Colors.blue),
                    SizedBox(height: 4),
                    Text(
                      "Ürün Adedi",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "12",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
                SizedBox(width: 20),
                // Satış adedi
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shopping_cart, size: 25, color: Colors.green),
                    SizedBox(height: 4),
                    Text(
                      "Satış Adedi",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "23",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            /*Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Ürün adedi
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inventory, size: 25, color: Colors.blue),
                    SizedBox(height: 4),
                    Text(
                      "Ürün Adedi",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "12",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
                SizedBox(width: 20),
                // Satış adedi
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shopping_cart, size: 25, color: Colors.green),
                    SizedBox(height: 4),
                    Text(
                      "Satış Adedi",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "23",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),*/
            // Satıcının İlanları Başlığı
            const Text(
              "Satıcının İlanları:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // İlanlar Grid Görünümü
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _getListings(listingIds),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text('Bir hata oluştu.'));
                  }

                  final listings = snapshot.data ?? [];

                  if (listings.isEmpty) {
                    return const Center(
                      child: Text(
                        "Satıcının hiçbir ilanı bulunmamaktadır.",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: EdgeInsets.all(8.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8.0,
                      crossAxisSpacing: 8.0,
                      childAspectRatio: 1,
                    ),
                    itemCount: listings.length,
                    itemBuilder: (context, index) {
                      final ilan = listings[index];

                      return buildIlanCard(
                        userId: sellerData['uid'],
                        baslik: ilan['baslik'],
                        fiyat: (ilan['fiyat'] != null
                            ? ilan['fiyat'].toDouble()
                            : 0),
                        resimUrl: ilan['resimler']?.isNotEmpty == true
                            ? ilan['resimler'][0]
                            : null,
                        ilanID: listingIds[index],
                        context: context,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Şikayet ekranı için bir dialog gösterme fonksiyonu
  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Satıcıyı Şikayet Et"),
          content: Text("Satıcıyı şikayet etmek istediğinizden emin misiniz?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Dialogu kapat
              },
              child: Text("İptal"),
            ),
            ElevatedButton(
              onPressed: () {
                // Şikayet işlemini gerçekleştir
                Navigator.pop(context); // Dialogu kapat
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Şikayetiniz gönderildi.")),
                );
              },
              child: Text("Şikayet Et"),
            ),
          ],
        );
      },
    );
  }
}
