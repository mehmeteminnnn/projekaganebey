import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:projekaganebey/satici.dart';
import 'package:projekaganebey/services/user_services.dart';
import 'package:projekaganebey/widgets/benzer_ilanlar.dart';

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
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _replyController = TextEditingController();
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
          final detay = ilanData['aciklama'] ?? 'Detay Yok';

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
                            mainAxisAlignment: MainAxisAlignment
                                .spaceBetween, // Sağda buton yerleştirmek için
                            children: [
                              Row(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SellerPage(sellerData: sellerData),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Satıcıyı Gör',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 20),
                      const Text(
                        "Son Yorumlar",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),

                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('comments')
                            .where('ilanId', isEqualTo: widget.ilanId)
                            .orderBy('timestamp', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            debugPrint('Hata: ${snapshot.error}');
                            return Center(
                                child: Text('Hata: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Center(
                              child: Text(
                                'Henüz yorum yapılmamış.',
                                style: TextStyle(
                                    color: Colors.orange.shade500,
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic),
                              ),
                            );
                          }

                          final comments = snapshot.data!.docs;

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              final comment = comments[index];
                              final commentId = comment.id;
                              debugPrint('Comment ID: $commentId');
                              final userName =
                                  comment['userName'] ?? 'Bilinmeyen Kullanıcı';
                              final commentText = comment['comment'] != null
                                  ? comment['comment']
                                  : 'Yorum yok';
                              final timestamp =
                                  (comment['timestamp'] as Timestamp).toDate();

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor:
                                              Colors.orange.shade300,
                                          child: Text(
                                            userName[0].toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                userName,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              Text(
                                                DateFormat('d MMM yyyy, HH:mm')
                                                    .format(timestamp),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 48),
                                      child: Text(
                                        commentText,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    const Divider(),

                                    // Yanıt verme butonu
                                    Padding(
                                      padding: const EdgeInsets.only(left: 48),
                                      child: TextButton(
                                        onPressed: () {
                                          _showReplyForm(commentId);
                                        },
                                        child: const Text(
                                          "Yanıtla",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Yanıtları göster bölümü
                                    Padding(
                                      padding: const EdgeInsets.only(left: 48),
                                      child: StreamBuilder<QuerySnapshot>(
                                        stream: FirebaseFirestore.instance
                                            .collection('replys')
                                            .where('parentCommentId',
                                                isEqualTo: commentId)
                                            .orderBy('timestamp',
                                                descending: true)
                                            .snapshots(),
                                        builder: (context, replySnapshot) {
                                          debugPrint(
                                              'Reply Snapshot: ${replySnapshot.data}');
                                          if (!replySnapshot.hasData ||
                                              replySnapshot
                                                  .data!.docs.isEmpty) {
                                            return const SizedBox
                                                .shrink(); // Yanıt yoksa boş bırak
                                          }

                                          final replies =
                                              replySnapshot.data!.docs;

                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              TextButton(
                                                onPressed: () {
                                                  // Yanıtları aç/kapat mantığı eklenebilir
                                                },
                                                child: const Text(
                                                  "Yanıtları göster",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.orange,
                                                  ),
                                                ),
                                              ),
                                              for (var reply in replies)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 16, top: 8),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      CircleAvatar(
                                                        radius: 16,
                                                        backgroundColor: Colors
                                                            .orange.shade200,
                                                        child: Text(
                                                          (reply['userName'] ??
                                                                  'U')[0]
                                                              .toUpperCase(),
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              reply['userName'] ??
                                                                  'Bilinmeyen Kullanıcı',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black87,
                                                              ),
                                                            ),
                                                            Text(
                                                              reply['replyText'] ??
                                                                  'Yanıt yok',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .black87,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
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

                      SizedBox(height: 20),

                      TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          filled: true, // Arka plan rengini etkinleştirir
                          fillColor: Colors
                              .orange.shade50, // Açık turuncu arka plan rengi
                          hintText: "Satıcıya soru sor",

                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.send,
                              color: Colors
                                  .orange, // Gönder ikonunun turuncu rengi
                            ),
                            onPressed: _addComment,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                12), // Yuvarlatılmış köşeler
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.orange.shade700,
                                width: 2), // Odaklanıldığında daha koyu turuncu
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
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
                          label: const Text("Ödemeye Geç"),
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
                      const SizedBox(height: 20),
                      const Text(
                        "Benzer İlanlar",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 20),
                      benzerIlanlarWidget(widget.ilanId, widget.id ?? ''),
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

  // Yanıt formunu gösteren fonksiyon
  void _showReplyForm(String commentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Yanıtınızı yazın"),
          content: TextField(
            controller: _replyController, // Yanıt yazma alanı
            decoration: const InputDecoration(
              hintText: 'Yanıtınızı buraya yazın...',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Yanıtı Firestore'a ekle
                _submitReply(commentId);
                Navigator.of(context).pop();
              },
              child: const Text("Gönder"),
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

// Yanıtı Firestore'a gönderme fonksiyonu
  void _submitReply(String commentId) {
    FirebaseFirestore.instance.collection('replys').add({
      'parentCommentId': commentId, // Yanıt verilen yorumun ID'si
      'replyText': _replyController.text,
      'timestamp': FieldValue.serverTimestamp(),
      'userName': 'Current User', // Kullanıcı adı
      'ilanId': widget.ilanId, // İlan ID'si
    });
  }

  void _addComment() async {
    if (_commentController.text.isNotEmpty) {
      final userId = widget.id; // Kullanıcı ID'si
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      // Kullanıcı bilgilerini almak
      if (userDoc.exists) {
        final userName =
            userDoc['name']; // 'name' alanının doğru olduğundan emin olun

        // Yorum ekleme işlemi
        await FirebaseFirestore.instance.collection('comments').add({
          'userId': userId, // Kullanıcı ID'si burada girilmeli
          'userName': userName, // Kullanıcı adı burada ekleniyor
          'comment': _commentController.text,
          'timestamp': FieldValue.serverTimestamp(),
          'ilanId':
              widget.ilanId, // Yorumun hangi ilana ait olduğunu belirten ID
        });

        // Yorum ekleme işlemi tamamlandığında, TextField'ı temizle
        _commentController.clear();
      } else {
        debugPrint('Kullanıcı bulunamadı!');
      }
    }
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
