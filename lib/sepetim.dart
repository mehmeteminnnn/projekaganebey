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
  late Future<List<IlanModel>> sepetListesi;
  double toplamTutar = 0.0;

  Future<List<IlanModel>> getSepetData(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        List<String> urunIds = List<String>.from(userDoc['sepetim'] ?? []);
        List<IlanModel> urunler = [];
        double tempToplamTutar = 0.0;

        debugPrint("Sepet ID'leri: $urunIds");

        for (var urunId in urunIds) {
          final ilanDoc = await FirebaseFirestore.instance
              .collection('ilanlar')
              .doc(urunId)
              .get();

          if (ilanDoc.exists) {
            var ilanData = ilanDoc.data()!;
            IlanModel ilan = IlanModel.fromMap({
              'id': urunId,
              'baslik': ilanData['baslik'],
              'fiyat': ilanData['fiyat'],
              'resimler': ilanData['resimler'],
            }, ilanDoc.id);
            urunler.add(ilan);
            tempToplamTutar += ilan.fiyat ?? 0.0;
            debugPrint("İlan Başlığı: ${ilan.baslik} - Fiyat: ${ilan.fiyat}");
          } else {
            debugPrint("İlan ID'si bulunamadı: $urunId");
          }
        }

        setState(() {
          toplamTutar = tempToplamTutar;
        });

        debugPrint("Toplam Tutar: $toplamTutar");

        return urunler;
      } else {
        debugPrint("Kullanıcı bulunamadı");
        return [];
      }
    } catch (e) {
      debugPrint('Hata oluştu: $e');
      throw Exception('Veri alırken hata oluştu: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    sepetListesi = getSepetData(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Sepetim",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: FutureBuilder<List<IlanModel>>(
        future: sepetListesi,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            debugPrint('Hata: ${snapshot.error}');
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

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
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            urunler[index].resimler?[0] ??
                                'https://ideacdn.net/idea/ar/16/myassets/products/353/pr_01_353.jpg?revision=1697143329',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          urunler[index].baslik ?? 'Başlık Yok',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text(
                          "Fiyat: ₺${urunler[index].fiyat?.toStringAsFixed(2)}",
                          style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            // Ürün silme işlemi
                            debugPrint("${urunler[index].baslik} silindi");
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
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8.0,
                            spreadRadius: 2.0,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "Toplam Tutar: ₺${toplamTutar.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              // Sepetle ödeme işlemi için bir yönlendirme yapılabilir
                              debugPrint("Ödeme işlemi başlatıldı");
                            },
                            child: const Text("Ödeme Yap",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.orange, // Buton rengi
                            ),
                          ),
                        ],
                      ),
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
