import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projekaganebey/models/ilan.dart';

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
        double tempToplamTutar = 0.0;

        // Sepet içeriğini işle
        for (var sepetItem in sepetimList) {
          final productId = sepetItem['id'];
          final miktar = sepetItem['miktar'];

          final ilanDoc = await FirebaseFirestore.instance
              .collection('ilanlar')
              .doc(productId)
              .get();

          if (ilanDoc.exists) {
            var ilanData = ilanDoc.data()!;

            IlanModel ilan = IlanModel.fromMap({
              'id': productId,
              'baslik': ilanData['baslik'],
              'fiyat': ilanData['fiyat'],
              'resimler': ilanData['resimler'],
              'miktar': miktar,
            }, ilanDoc.id);
            urunler.add(ilan);
            tempToplamTutar += (ilan.fiyat ?? 0.0) * (miktar ?? 1);
          }
        }

        setState(() {
          toplamTutar = tempToplamTutar;
        });

        return urunler;
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Veri alırken hata oluştu: $e');
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
        title: const Text('Silme İşlemi'),
        content: const Text(
            'Bu ürünü sepetinizden silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // İptal
            child: const Text('Hayır'),
          ),
          TextButton(
            onPressed: () {
              _removeFromCart(productId, urunler);
              Navigator.of(context).pop(); // Sil ve kapat
            },
            child: const Text('Evet'),
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

                    return Card(
                      child: ListTile(
                        leading: Image.network(
                          urunler[index].resimler?[0] ?? '',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                        title: Text(urunler[index].baslik ?? ''),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "Fiyat: ₺${urunler[index].fiyat?.toStringAsFixed(2)}"),
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
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Text("Toplam: ₺${toplamTutar.toStringAsFixed(2)}"),
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
