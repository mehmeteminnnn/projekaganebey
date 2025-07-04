import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:Depot/ilan_detay.dart';

class FavorilerimPage extends StatefulWidget {
  final String? id;
  const FavorilerimPage({Key? key, this.id}) : super(key: key);

  @override
  State<FavorilerimPage> createState() => _FavorilerimPageState();
}

class _FavorilerimPageState extends State<FavorilerimPage> {
  Stream<List<String>> _getFavorilerimStream(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data();
      if (data != null && data.containsKey('favorilerim')) {
        return List<String>.from(data['favorilerim']);
      } else {
        return [];
      }
    });
  }

  Future<Map<String, dynamic>?> _getIlanDetaylari(String ilanId) async {
    List<String> koleksiyonlar = ['mdf_lam', 'osb', 'panel', 'sunta'];

    for (String koleksiyon in koleksiyonlar) {
      final doc = await FirebaseFirestore.instance
          .collection(koleksiyon)
          .doc(ilanId)
          .get();

      if (doc.exists) {
        return doc.data();
      }
    }

    return null; // Hiçbir koleksiyonda ilan bulunamazsa null döndür
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Favorilerim",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<List<String>>(
        stream: _getFavorilerimStream(widget.id!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Bir hata oluştu: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final favoriler = (snapshot.data ?? []).reversed.toList();

          if (favoriler.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border,
                      size: 100, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    "Favorileriniz boş",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Henüz favorilere ilan eklemediniz.",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.9, // Öğelerin yüksekliğini ayarlar
              ),
              itemCount: favoriler.length,
              itemBuilder: (context, index) {
                final ilanId = favoriler[index];

                return FutureBuilder<Map<String, dynamic>?>(
                  future: _getIlanDetaylari(ilanId),
                  builder: (context, ilanSnapshot) {
                    if (ilanSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (ilanSnapshot.hasError || !ilanSnapshot.hasData) {
                      return Container(
                        alignment: Alignment.center,
                        color: Colors.grey.shade200,
                        child: const Text("İlan bilgileri yüklenemedi."),
                      );
                    }

                    final ilan = ilanSnapshot.data!;
                    final resim = ilan['resimler']?.isNotEmpty == true
                        ? ilan['resimler'][0]
                        : null;
                    final baslik = ilan['baslik'] ?? "Başlık Yok";

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => IlanDetayPage(
                              id: widget.id,
                              ilanId: ilanId,
                              ilanbaslik: baslik,
                            ),
                          ),
                        );
                      },
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: resim != null
                                  ? DecorationImage(
                                      image: NetworkImage(resim),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                              color: Colors.grey.shade200,
                            ),
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(12),
                                ),
                              ),
                              child: Text(
                                baslik,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon:
                                  const Icon(Icons.favorite, color: Colors.red),
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(widget.id)
                                    .update({
                                  'favorilerim':
                                      FieldValue.arrayRemove([ilanId]),
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text("Favorilerden kaldırıldı.")),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
