import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Depot/services/user_services.dart';
import 'package:Depot/widgets/ilan_card.dart';

class SellerPage extends StatelessWidget {
  final Map<String, dynamic> sellerData;

  const SellerPage({Key? key, required this.sellerData}) : super(key: key);

  Future<List<Map<String, dynamic>>> _getListings(
      List<dynamic> listingIds) async {
    final List<Map<String, dynamic>> listings = [];
    final List<String> collections = [
      'ilanlar',
      'mdf_lam',
      'osb_panel',
      'sunta'
    ];

    for (var collection in collections) {
      final results = await Future.wait(
        listingIds.map((listingId) async {
          var doc = await FirebaseFirestore.instance
              .collection(collection)
              .doc(listingId)
              .get();
          return doc.exists ? doc.data() as Map<String, dynamic>? : null;
        }),
      );

      listings.addAll(results.whereType<Map<String, dynamic>>());
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
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "report") {
                _showReportDialog(context);
              } else if (value == "rate") {
                _showRatingDialog(context);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: "report",
                  child: Text("Satıcıyı Şikayet Et"),
                ),
                const PopupMenuItem(
                  value: "rate",
                  child: Text("Satıcıyı Değerlendir"),
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundImage:
                      sellerPhoto.isNotEmpty ? NetworkImage(sellerPhoto) : null,
                  child: sellerPhoto.isEmpty
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sellerData['name'] ?? 'Bilinmeyen Satıcı',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
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
                const SizedBox(width: 35),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  //mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.inventory, size: 25, color: Colors.blue),
                    const SizedBox(height: 4),
                    const Text(
                      "Ürün Adedi",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sellerData['productCount']?.toString() ?? "0",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Satıcının İlanları:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
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
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Satıcıyı Şikayet Et"),
          content:
              const Text("Satıcıyı şikayet etmek istediğinizden emin misiniz?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("İptal"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Şikayetiniz gönderildi.")),
                );
              },
              child: const Text("Şikayet Et"),
            ),
          ],
        );
      },
    );
  }

  void _showRatingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Satıcıyı Değerlendir"),
          content: const Text("Lütfen satıcıyı yıldızlarla değerlendirin."),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: const Icon(Icons.star, color: Colors.grey),
                  onPressed: () {
                    _rateSeller(index + 1, context);
                    Navigator.of(context).pop();
                  },
                );
              }),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("İptal"),
            ),
          ],
        );
      },
    );
  }

  void _rateSeller(int rating, BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(sellerData['uid'])
        .update({
      'rating': rating,
      'değerlendiren': FieldValue.increment(1),
    });

    /* ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Satıcı puanı güncellendi: $rating")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Puan güncellenirken hata oluştu.")),
      );*/
  }
}
