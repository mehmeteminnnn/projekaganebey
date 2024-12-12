import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projekaganebey/models/ilan.dart';
import 'package:projekaganebey/services/user_services.dart';

class SepetimPage extends StatefulWidget {
  final String userId;

  const SepetimPage({Key? key, required this.userId}) : super(key: key);

  @override
  _SepetimPageState createState() => _SepetimPageState();
}

class _SepetimPageState extends State<SepetimPage> {
  double toplamTutar = 0.0;

  // Sepet verilerini al
  Future<List<IlanModel>> getSepetData(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        List<Map<String, dynamic>> sepetimList =
            List<Map<String, dynamic>>.from(userDoc['sepetim'] ?? []);
        List<IlanModel> urunler = [];
        Map<String, Map<String, dynamic>> saticiBilgileri =
            {}; // Satıcı bilgileri
        double tempToplamTutar = 0.0;

        for (var sepetItem in sepetimList) {
          final productId = sepetItem['id'];
          final miktar = sepetItem['miktar'];

          final ilanDoc = await FirebaseFirestore.instance
              .collection('ilanlar')
              .doc(productId)
              .get();

          if (ilanDoc.exists) {
            var ilanData = ilanDoc.data()!;
            final saticiId = ilanData['olusturanKullaniciId'];

            // Satıcı bilgilerini bir kez alın
            if (!saticiBilgileri.containsKey(saticiId)) {
              final saticiDoc = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(saticiId)
                  .get();

              if (saticiDoc.exists) {
                saticiBilgileri[saticiId] = {
                  'name': saticiDoc.data()?['name'] ?? 'Bilinmeyen Satıcı',
                  'photo': saticiDoc.data()?['photo'] ??
                      "https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png?20150327203541", // Varsayılan fotoğraf URL'si
                  'rating': saticiDoc.data()?['rating']?.toDouble() ?? 0.0,
                };
              } else {
                saticiBilgileri[saticiId] = {
                  'name': 'Bilinmeyen Satıcı',
                  'photo':
                      "https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png?20150327203541", // Varsayılan fotoğraf URL'si
                  'rating': 0.0,
                };
              }
            }

            // Satıcı bilgilerini al
            final sellerInfo = saticiBilgileri[saticiId]!;

            // Satıcı adı, fotoğrafı ve puanı için null kontrolü ve varsayılan değer ataması
            final sellerName =
                sellerInfo['name'] ?? "Bilinmeyen Satıcı"; // Varsayılan değer
            final sellerPhoto = sellerInfo['photo'] ??
                "https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png?20150327203541"; // Varsayılan fotoğraf URL'si
            final sellerRating =
                sellerInfo['rating']?.toDouble() ?? 0.0; // Varsayılan puan 0.0

            IlanModel ilan = IlanModel.fromMap({
              'id': productId,
              'baslik': ilanData['baslik'],
              'fiyat': ilanData['fiyat'],
              'resimler': ilanData['resimler'],
              'miktar': miktar,
              'olusturanKullaniciId': saticiId,
              'saticiAdi': sellerName,
              'saticiFotografi': sellerPhoto,
              'saticiPuan': sellerRating,
            }, ilanDoc.id);

            urunler.add(ilan);
            tempToplamTutar += (ilan.fiyat ?? 0.0) * (miktar ?? 1);
          } else {
            print("Ürün $productId verisi mevcut değil.");
          }
        }

        setState(() {
          toplamTutar = tempToplamTutar;
        });

        return urunler;
      } else {
        print("Kullanıcı verisi mevcut değil.");
        return [];
      }
    } catch (e) {
      print("Hata oluştu: $e");
      return [];
    }
  }

  Future<void> updateMiktar(String productId, int miktar) async {
    try {
      final ilanDoc = await FirebaseFirestore.instance
          .collection('ilanlar')
          .doc(productId)
          .get();

      var ilanData = ilanDoc.data()!;
      int maxMiktar = ilanData['miktar'];
      if (miktar < 1) {
        miktar = 1; // Miktar minimum 1 olmalı
      } else if (miktar > maxMiktar) {
        // Eğer miktar maxMiktar'ı aşarsa uyarı göster
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(
              'Miktar Hatası',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text('Bu üründen stokta yalnızca $maxMiktar tane var '),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child:
                    const Text('Tamam', style: TextStyle(color: Colors.orange)),
              ),
            ],
          ),
        );
        return; // Uyarı gösterildikten sonra işlem yapılmaz
      }

      final userRef =
          FirebaseFirestore.instance.collection('users').doc(widget.userId);

      // Aynı ID'ye sahip bir ürün zaten varsa miktarını güncelle
      final userDoc = await userRef.get();
      List<Map<String, dynamic>> sepetimList =
          List<Map<String, dynamic>>.from(userDoc['sepetim'] ?? []);
      bool found = false;
      for (var item in sepetimList) {
        if (item['id'] == productId) {
          item['miktar'] = miktar;
          found = true;
          break;
        }
      }

      // Eğer ürün zaten sepette yoksa, yeni ürün ekle
      if (!found) {
        sepetimList.add({'id': productId, 'miktar': miktar});
      }

      await userRef.update({
        'sepetim': sepetimList,
      });

      setState(() {});
    } catch (e) {
      debugPrint('Miktar güncellenirken hata oluştu: $e');
    }
  }

  // Ürün silme işlemi
  Future<void> showDeleteConfirmation(
      String productId, List<IlanModel> urunler) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Silme İşlemi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
            'Bu ürünü sepetinizden silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // İptal
            child: const Text('Hayır', style: TextStyle(color: Colors.orange)),
          ),
          TextButton(
            onPressed: () {
              _removeFromCart(productId, urunler);
              Navigator.of(context).pop(); // Sil ve kapat
            },
            child: const Text('Evet', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  Future<void> _removeFromCart(
      String productId, List<IlanModel> urunler) async {
    try {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(widget.userId);

      // Silinecek ürünün bilgilerini al
      final removedProduct = urunler.firstWhere((urun) => urun.id == productId);
      final removedProductPrice = removedProduct.fiyat ?? 0.0;
      final removedProductQuantity = removedProduct.miktar ?? 1;

      // Sepetten ilgili ürünü tamamen çıkar
      await userRef.update({
        'sepetim': FieldValue.arrayRemove([
          {'id': productId, 'miktar': removedProductQuantity},
        ]),
      });

      // Toplam tutarı güncelle
      setState(() {
        toplamTutar -= removedProductPrice * removedProductQuantity;
      });
    } catch (e) {
      debugPrint('Ürün silinirken hata oluştu: $e');
    }
  }

  void _showDetailModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sepet Detayları',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Ürün Fiyatı:', style: TextStyle(fontSize: 16)),
                  Text('₺${(toplamTutar).toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Alıcı Koruma Hizmeti:',
                      style: TextStyle(fontSize: 16)),
                  const Text('₺25.00', style: TextStyle(fontSize: 16)),
                ],
              ),
              const Divider(height: 32, thickness: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Toplam:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('₺${(toplamTutar + 25.0).toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Sepetim",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<List<IlanModel>>(
        stream: Stream.fromFuture(getSepetData(widget.userId)),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }
          //debugPrint('Sepet verileri: ${snapshot.data?.first.fiyat}');
          //debugPrint('${snapshot.data?.first.olusturanKullaniciId} satıcı');

          final urunler = snapshot.data ?? [];

          if (urunler.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 100, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text("Sepetiniz boş",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey)),
                  const SizedBox(height: 8),
                  const Text("Henüz ürün eklemediniz.",
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                ListView.builder(
                  itemCount: urunler.length,
                  itemBuilder: (context, index) {
                    //int maxMiktar = urunler[index].miktar ?? 1;

                    //  debugPrint('Sepet verileri: ${urunler.length}');

                    return Card(
                      color: Colors.white,
                      child: ListTile(
                        leading: Image.network(
                          urunler[index].resimler != null &&
                                  urunler[index].resimler!.isNotEmpty
                              ? urunler[index].resimler![0]
                              : 'https://via.placeholder.com/60',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                        title: Text(
                          urunler[index].baslik ?? '',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "Fiyat: ₺${urunler[index].fiyat?.toStringAsFixed(2)}"),
                            /*Text(
                                "Miktar: ${urunler[index].olusturanKullaniciId}"),*/
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Satıcı Bilgileri Başlığı
                                Row(
                                  children: [
                                    // Satıcı Adı
                                    Text(
                                      "Satıcı: ${urunler[index].saticiAdi}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                    height:
                                        1), // Satıcı adı ile puan arasına boşluk ekledik
                                // Satıcı Puanı
                                Row(
                                  children: [
                                    // Yıldız ikonu
                                    Icon(
                                      Icons.star,
                                      color: Colors.orange,
                                      size: 16,
                                    ),
                                    SizedBox(
                                        width:
                                            4), // Yıldız ve puan arasında boşluk
                                    Text(
                                      "${urunler[index].saticiPuan} / 5",
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (urunler[index].miktar! > 1) {
                                      updateMiktar(
                                        urunler[index].id!,
                                        urunler[index].miktar! - 1,
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.remove),
                                ),
                                Text('${urunler[index].miktar}'),
                                IconButton(
                                  onPressed: () {
                                    updateMiktar(
                                      urunler[index].id!,
                                      urunler[index].miktar! + 1,
                                    );
                                  },
                                  icon: const Icon(Icons.add),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDeleteConfirmation(urunler[index].id!, urunler);
                          },
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _showDetailModal, // Detay modali açılır
                              child: Row(
                                children: const [
                                  Icon(Icons.info_outline,
                                      color: Colors.grey), // Detay ikonu
                                ],
                              ),
                            ),
                            const SizedBox(
                                width: 16), // Detay ve toplam arasında boşluk
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Toplam:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '₺${(toplamTutar + 25.0).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          onPressed: () {
                            // Ödeme işlemi yapılır
                          },
                          child: const Text(
                            'Ödemeye Geç',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
