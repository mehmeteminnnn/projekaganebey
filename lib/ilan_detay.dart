import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projekaganebey/services/user_services.dart';

class IlanDetayPage extends StatefulWidget {
  final String ilanId;
  final String? ilanbaslik;
  final String? id;

  const IlanDetayPage(
      {Key? key, required this.ilanId, this.ilanbaslik, this.id})
      : super(key: key);

  @override
  State<IlanDetayPage> createState() => _IlanDetayPageState();
}

class _IlanDetayPageState extends State<IlanDetayPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 0;
  bool isFavorited = false;
  int _quantity = 1;
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      debugPrint('Scroll Offset: ${_scrollController.offset}');
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkIfFavorited();
    debugPrint('ilanId: ${widget.ilanId}, id: ${widget.id}');
  }

  void _checkIfFavorited() async {
    try {
      final favorited =
          await UserService().isFavorited(widget.id!, widget.ilanId);
      if (mounted) {
        setState(() {
          isFavorited = favorited;
        });
      }
    } catch (e) {
      // ScaffoldMessenger çağrısını doğrudan burada değil, güvenli bir yerden yapmalısınız
      Future.microtask(() {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bir hata oluştu: $e')),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveMixin için gerekli
    final ilanRef =
        FirebaseFirestore.instance.collection('ilanlar').doc(widget.ilanId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.ilanbaslik}',
          style: const TextStyle(
            fontSize: 18,
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
            icon: Icon(
              isFavorited ? Icons.favorite : Icons.favorite_border,
              color: isFavorited ? Colors.red : null,
            ),
            onPressed: () async {
              setState(() {
                isFavorited = !isFavorited;
              });

              final userRef =
                  FirebaseFirestore.instance.collection('users').doc(widget.id);

              try {
                final userDoc = await userRef.get();

                if (userDoc.exists) {
                  // Kullanıcı mevcutsa güncelle
                  if (isFavorited) {
                    // Favorilere ekle
                    await userRef.update({
                      'favorilerim': FieldValue.arrayUnion([widget.ilanId]),
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Favorilere eklendi!')),
                    );
                  } else {
                    // Favorilerden çıkar
                    await userRef.update({
                      'favorilerim': FieldValue.arrayRemove([widget.ilanId]),
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Favorilerden çıkarıldı!')),
                    );
                  }
                } else {
                  // Kullanıcı dokümanı yoksa oluştur ve favorilerim alanını ekle
                  await userRef.set({
                    'favorilerim': [widget.ilanId],
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Favorilere eklendi!')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Bir hata oluştu: $e')),
                );
              }
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
          final detay = ilanData['detay'] ?? 'Detay Yok';

          return SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Resim galerisi
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    SizedBox(
                      height: 250,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: resimler.length,
                        itemBuilder: (context, index) {
                          return Image.network(
                            resimler[index],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image_not_supported,
                                    size: 100),
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
                            width: 12,
                            height: 12,
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
                const SizedBox(height: 20),
                // Ürün detayları
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 6,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fiyat bilgisi
                      Text(
                        "$fiyat TL",
                        style: const TextStyle(
                          fontSize: 26,
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
                      const SizedBox(height: 20),
                      // Ürün özellikleri başlığı
                      const Text(
                        "Ürün Özellikleri",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureRow("İl", il, "İlçe", ilce),
                      const SizedBox(height: 16),
                      _buildFeatureRow("Miktar", "$miktar Adet", "Yükseklik",
                          "$yukseklik cm"),
                      const SizedBox(height: 16),
                      _buildFeatureRow("Genişlik", "$genislik cm", "En",
                          "${ilanData['en']} cm"),
                      const SizedBox(height: 16),
                      _buildFeatureRow("Renk", renk, "Kategori", kategori),

                      const SizedBox(height: 20),
                      // Ürün açıklama
                      const Text(
                        "Detaylı Açıklama",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Text(detay,
                          style: const TextStyle(
                              fontSize: 16, color: Colors.grey)),

                      const SizedBox(height: 20),
                      const Text(
                        "Satıcı Bilgileri",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      FutureBuilder<Map<String, dynamic>?>(
                        future: UserService().getCreatorInfo(widget.ilanId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Text('Hata: ${snapshot.error}');
                          } else if (!snapshot.hasData ||
                              snapshot.data == null) {
                            return const Text('Satıcı bilgileri bulunamadı.');
                          }

                          final sellerData = snapshot.data!;
                          final sellerName =
                              sellerData['name'] ?? 'Bilinmeyen Satıcı';
                          final sellerPhoto = sellerData['photo'] ?? '';
                          final sellerRating = sellerData['rating'] ?? 0;

                          return Row(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundImage: sellerPhoto.isNotEmpty
                                    ? NetworkImage(sellerPhoto)
                                    : null,
                                child: sellerPhoto.isEmpty
                                    ? const Icon(Icons.person, size: 24)
                                    : null,
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    sellerName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: List.generate(
                                      5,
                                      (index) => Icon(
                                        Icons.star,
                                        color: index < sellerRating
                                            ? Colors.orange
                                            : Colors.grey,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // Miktar Seçim Butonları
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            color: Colors.orange,
                            onPressed: () {
                              if (_quantity > 1) {
                                _quantity--;
                                // Scroll kontrolüne dokunmadan miktarı güncelle
                                setState(() {});
                              }
                            },
                          ),
                          Text(
                            '$_quantity',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Miktar kontrolü eklendi
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            color: Colors.orange,
                            onPressed: () {
                              setState(() {
                                if (_quantity < int.parse(miktar)) {
                                  _quantity++; // Miktarı arttır
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Stok sınırına ulaşıldı!')),
                                  );
                                }
                              });
                            },
                          ),
                        ],
                      ),

// Sepete Ekle Butonu
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            // Sepette olup olmadığını kontrol et
                            final isInCart = await UserService()
                                .isProductInCart(widget.id!, widget.ilanId);

                            if (isInCart) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Sepetinizde bu ürün zaten var!')),
                              );
                            } else {
                              // Sepete ekle
                              await UserService().addToCart(
                                context,
                                widget.id!,
                                widget.ilanId,
                                _quantity.toInt(),
                              );
                            }
                          },
                          icon: const Icon(Icons.shopping_cart),
                          label: const Text("Sepete Ekle"),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
            color: Colors.black,
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
        const SizedBox(width: 20),
        Expanded(child: _buildFeature(title2, value2)),
      ],
    );
  }
}
