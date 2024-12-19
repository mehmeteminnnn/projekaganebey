import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
        title: const Text("Satıcı Bilgileri"),
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
                  radius: 50,
                  backgroundImage: (sellerPhoto.isNotEmpty
                      ? NetworkImage(sellerPhoto)
                      : null),
                  child: sellerPhoto.isEmpty
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      sellerData['name'] ?? 'Bilinmeyen Satıcı',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          Icons.star,
                          color: index < (sellerData['rating'] ?? 0)
                              ? Colors.orange
                              : Colors.grey,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Puan: ${(sellerData['rating'] ?? 0)}/5",
                      style:
                          const TextStyle(fontSize: 16, color: Colors.orange),
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
                future: _getListings(
                    listingIds), // Firestore'dan ilan verilerini al.
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
}
