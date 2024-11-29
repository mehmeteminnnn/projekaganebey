import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IlanDetayPage extends StatefulWidget {
  final String ilanId;
  final String? ilanbaslik;

  const IlanDetayPage({Key? key, required this.ilanId, this.ilanbaslik})
      : super(key: key);

  @override
  State<IlanDetayPage> createState() => _IlanDetayPageState();
}

class _IlanDetayPageState extends State<IlanDetayPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0; // Aktif sayfayı tutar

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ilanRef =
        FirebaseFirestore.instance.collection('ilanlar').doc(widget.ilanId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.ilanbaslik}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Paylaşım işlemi
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // Favorilere ekleme işlemi
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: ilanRef.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Bir hata oluştu: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text("İlan bulunamadı."),
            );
          }

          final ilanData = snapshot.data!.data() as Map<String, dynamic>;
          final resimler = List<String>.from(ilanData['resimler'] ?? []);
          final fiyat = ilanData['fiyat']?.toString() ?? '0';
          final il = ilanData['il'] ?? 'İl Yok';
          final ilce = ilanData['ilce'] ?? 'İlçe Yok';
          final kategori = ilanData['kategori'] ?? 'Kategori Yok';
          final miktar = ilanData['miktar']?.toString() ?? '0';
          final yukseklik = ilanData['yukseklik']?.toString() ?? '0';
          final genislik = ilanData['genislik']?.toString() ?? '0';
          final renk = ilanData['renk'] ?? 'Renk Yok';

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Resim galerisi
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    SizedBox(
                      height: 300, // Sabit yükseklik
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemCount: resimler.length,
                        itemBuilder: (context, index) {
                          return Image.network(
                            resimler[index],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.image_not_supported,
                              size: 100,
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          resimler.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 12 : 8,
                            height: _currentPage == index ? 12 : 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? Colors.orange
                                  : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Ürün detayları
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fiyat bilgisi
                      Text(
                        "$fiyat TL",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const Text(
                        "Birim Adet Fiyatı",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Ürün özellikleri
                      const Text(
                        "Ürün Özellikleri",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildFeatureRow("İl", il, "İlçe", ilce),
                      const SizedBox(height: 8),
                      _buildFeatureRow("Miktar", "$miktar Adet", "Yükseklik",
                          "$yukseklik cm"),
                      const SizedBox(height: 8),
                      _buildFeatureRow(
                          "Genişlik", "$genislik cm", "Kategori", kategori),
                      const SizedBox(height: 8),
                      _buildFeature("Renk", renk),
                      const SizedBox(height: 16),
                      // Satın al butonu
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text('Satın Al',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Özellik widget'ı
  Widget _buildFeature(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Yan yana iki özellik gösterimi
  Widget _buildFeatureRow(
      String title1, String value1, String title2, String value2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: _buildFeature(title1, value1)),
        const SizedBox(width: 16),
        Expanded(child: _buildFeature(title2, value2)),
      ],
    );
  }
}
