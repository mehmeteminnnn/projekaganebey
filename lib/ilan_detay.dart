import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Depot/screens/satici.dart';
import 'package:Depot/services/user_services.dart';
import 'package:Depot/widgets/benzer_ilanlar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Depot/services/firestore_services.dart';
import 'package:flutter/services.dart';
import 'package:Depot/widgets/son_yorumlar.dart';
import 'package:intl/intl.dart';
import 'package:Depot/constants/constants.dart';
import 'dart:convert';
import 'package:turkish/turkish.dart';

class IlanDetayPage extends StatefulWidget {
  final String ilanId;
  final String? ilanbaslik;
  final String? id;
  final bool? kendiIlanim;
  final String? kategori;

  const IlanDetayPage(
      {Key? key,
      required this.ilanId,
      this.ilanbaslik,
      this.id,
      this.kendiIlanim,
      this.kategori})
      : super(key: key);

  @override
  State<IlanDetayPage> createState() => _IlanDetayPageState();
}

class _IlanDetayPageState extends State<IlanDetayPage> {
  final PageController _pageController = PageController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _replyController = TextEditingController();
  int _currentPage = 0;
  bool isFavorited = false;
  final GlobalKey _questionKey = GlobalKey();
  final FocusNode _focusNode = FocusNode();
  String? koleksiyon;

  @override
  void initState() {
    super.initState();
    if (widget.kendiIlanim != true) {
      _checkIfFavorited();
    }
    _loadCollectionName(); // Koleksiyon adını çek

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        debugPrint("TextField odaklandı");
      } else {
        debugPrint("TextField odak kaybetti");
      }
    });
  }

  Future<void> _loadCollectionName() async {
    final foundCollection = await findCollectionByIlanId(widget.ilanId);
    if (mounted) {
      setState(() {
        koleksiyon = foundCollection;
      });
    }
    debugPrint('Koleksiyon bulundu: $koleksiyon');
  }

  Future<String?> findCollectionByIlanId(String ilanId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<String> koleksiyonlar = ["mdf_lam", "osb", "panel", "sunta"];

    for (String koleksiyon in koleksiyonlar) {
      var snapshot = await firestore.collection(koleksiyon).doc(ilanId).get();
      if (snapshot.exists) {
        return koleksiyon; // İlan hangi koleksiyonda bulunduysa onu döndür
      }
    }

    return null; // Eğer ilan hiçbir koleksiyonda bulunamazsa null döner
  }

  void _ilanKaldirUyari(BuildContext context, String ilanId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Emin misiniz?"),
          content: const Text(
              "Bu ilanı yayından kaldırmak istediğinizden emin misiniz?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Uyarıyı kapat
              },
              child: const Text("İptal"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Uyarıyı kapat
                FirestoreService()
                    .ilanKaldir(ilanId); // Firestore işlemine başla
              },
              child: const Text("Evet, Kaldır"),
            ),
          ],
        );
      },
    );
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
      Future.microtask(() {
        if (mounted) {
          /* ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bir hata oluştu: $e')),
          );*/
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (koleksiyon == null) {
      return const Center(
          child: CircularProgressIndicator()); // Yüklenme durumu
    }

    final ilanRef =
        FirebaseFirestore.instance.collection(koleksiyon!).doc(widget.ilanId);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          '${widget.ilanbaslik ?? "Yeni İlan"}',
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
          if (widget.kendiIlanim != true)
            IconButton(
              icon: Icon(
                isFavorited ? Icons.favorite : Icons.favorite_border,
                color: isFavorited ? Colors.red : null,
              ),
              onPressed: () async {
                setState(() {
                  isFavorited = !isFavorited;
                });

                final userRef = FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.id);

                try {
                  final userDoc = await userRef.get();

                  if (userDoc.exists) {
                    if (isFavorited) {
                      await userRef.update({
                        'favorilerim': FieldValue.arrayUnion([widget.ilanId]),
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Favorilere eklendi!')),
                      );
                    } else {
                      await userRef.update({
                        'favorilerim': FieldValue.arrayRemove([widget.ilanId]),
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Favorilerden çıkarıldı!')),
                      );
                    }
                  } else {
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
          if (widget.kendiIlanim == true)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  ilanRef.get().then((snapshot) {
                    _showEditDialog(context, snapshot);
                  });
                } else if (value == 'remove') {
                  _ilanKaldirUyari(context, widget.ilanId);
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Text('İlanı Düzenle'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'remove',
                    child: Text('İlanı Yayından Kaldır'),
                  ),
                ];
              },
            )
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: ilanRef.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
                //  child: Text('Bir hata oluştu: ${snapshot.error}'),
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
          final timestamp = ilanData['timestamp'] as Timestamp?;
          final formattedDate = timestamp != null
              ? DateFormat('d MMM yyyy, HH:mm').format(timestamp.toDate())
              : 'Tarih yok';

          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        SizedBox(
                          height: 250,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: resimler.length,
                            onPageChanged: (value) {
                              setState(() {
                                _currentPage = value;
                              });
                            },
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
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
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
                          _buildFeatureRow("Miktar", "$miktar Adet",
                              "Yükseklik", "$yukseklik cm"),
                          const SizedBox(height: 16),
                          _buildFeatureRow("Genişlik", "$genislik cm", "En",
                              "${ilanData['en']} cm"),
                          const SizedBox(height: 16),
                          _buildFeatureRow("Renk", renk, "Kategori", kategori),
                          const SizedBox(height: 20),
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
                                return const Text(
                                    'Satıcı bilgileri bulunamadı.');
                              }

                              final sellerData = snapshot.data!;

                              final sellerName =
                                  sellerData['name'] ?? 'Bilinmeyen Satıcı';
                              final sellerPhoto = sellerData['photo'] ?? '';
                              final sellerRating = sellerData['rating'] ?? 0;
                              debugPrint("${widget.ilanId} ilan id");
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                          builder: (context) => SellerPage(
                                              sellerData: sellerData),
                                        ),
                                      );
                                    },
                                    child: const Text(
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
                          SonYorumlar(ilanId: widget.ilanId),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: _showQuestionModal,
                            child: Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                key: _questionKey,
                                children: const [
                                  Icon(Icons.edit, color: Colors.grey),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Satıcıya soru sor",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 80),
                          /* const Text(
                            "Benzer İlanlar",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 20),
                          benzerIlanlarWidget(widget.ilanId, widget.id ?? ''),*/
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.kendiIlanim != null && widget.kendiIlanim == false)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 150,
                          child: ElevatedButton(
                            onPressed: () async {
                              final phoneNumber = await FirestoreService()
                                  .getUserPhoneByIlanId(widget.ilanId);
                              if (phoneNumber != null) {
                                Clipboard.setData(
                                    ClipboardData(text: phoneNumber));
                                debugPrint(phoneNumber + " telefon bu");

                                final Uri launchUri = Uri(
                                  scheme: 'tel',
                                  path: phoneNumber,
                                );

                                if (await canLaunchUrl(launchUri)) {
                                  await launchUrl(launchUri);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Telefon numarası panoya kopyalandı!')),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Telefon uygulaması açılamadı!')),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Telefon numarası bulunamadı!')),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade300,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "Ara",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          width: 150,
                          child: ElevatedButton(
                            onPressed: () {
                              Scrollable.ensureVisible(
                                _questionKey.currentContext!,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade300,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "Mesaj Gönder",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /*void _showReplyForm(String commentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Yanıtınızı yazın"),
          content: TextField(
            controller: _replyController,
            decoration: const InputDecoration(
              hintText: 'Yanıtınızı buraya yazın...',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
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
  }*/

  /*void _submitReply(String commentId) {
    FirebaseFirestore.instance.collection('replys').add({
      'parentCommentId': commentId,
      'replyText': _replyController.text,
      'timestamp': FieldValue.serverTimestamp(),
      'userName': 'Current User',
      'ilanId': widget.ilanId,
    });
  }*/

  void _showQuestionModal() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  labelText: "Sorunuzu yazın",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _addComment();
                  Navigator.of(context).pop(); // Modalı kapat
                },
                child: const Text("Gönder"),
              ),
            ],
          ),
        );
      },
    );
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
        final userName = userDoc['name']; // Kullanıcı adı

        // Yorum ekleme işlemi
        await FirebaseFirestore.instance.collection('comments').add({
          'userId': userId,
          'userName': userName,
          'comment': _commentController.text,
          'timestamp': FieldValue.serverTimestamp(),
          'ilanId': widget.ilanId,
          'hasReply': false,
        });

        // Yorum ekleme işlemi tamamlandığında, TextField'ı temizle
        _commentController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Soru gönderildi!')),
        );
      } else {
        debugPrint('Kullanıcı bulunamadı!');
      }
    }
  }

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

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200, // Hafif gri arka plan
        borderRadius: BorderRadius.circular(12), // Yuvarlak köşeler
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600),
          border: InputBorder.none, // Border kaldırıldı
        ),
        maxLines: maxLines,
        keyboardType: keyboardType,
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String? selectedValue,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200, // Hafif gri arka plan
        borderRadius: BorderRadius.circular(12), // Yuvarlak köşeler
      ),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600),
          border: InputBorder.none, // Border kaldırıldı
        ),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  void _showEditDialog(BuildContext context, DocumentSnapshot ilanData) async {
    // Text controller'ları oluştur
    final baslikController = TextEditingController(text: ilanData['baslik']);
    final aciklamaController =
        TextEditingController(text: ilanData['aciklama']);
    final fiyatController =
        TextEditingController(text: ilanData['fiyat'].toString());
    final genislikController =
        TextEditingController(text: ilanData['genislik'].toString());
    final yukseklikController =
        TextEditingController(text: ilanData['yukseklik'].toString());
    final miktarController =
        TextEditingController(text: ilanData['miktar'].toString());

    // İl ve ilçe için değişkenler
    String selectedIl = ilanData['il'];
    String selectedIlce = ilanData['ilce'];
    String selectedUretici = ilanData['uretici'];
    String selectedRenk = ilanData['renk'];
    String? selectedCityId;
    List<Map<String, dynamic>> cities = [];
    List<dynamic> districts = [];

    // İlleri yükle
    String cityJson = await rootBundle.loadString('assets/il.json');
    cities = List<Map<String, dynamic>>.from(jsonDecode(cityJson));
    cities.sort((a, b) => turkish.comparator(a['name'], b['name']));

    // Seçili ilin ID'sini bul
    var selectedCity = cities.firstWhere(
      (city) => city['name'] == selectedIl,
      orElse: () => {'id': '', 'name': selectedIl},
    );
    selectedCityId = selectedCity['id'].toString();

    // İlçeleri yükle
    String districtJson = await rootBundle.loadString('assets/ilce.json');
    List<dynamic> allDistricts = jsonDecode(districtJson);
    districts =
        allDistricts.where((d) => d['il_id'] == selectedCityId).toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'İlanı Düzenle',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          contentPadding:
              const EdgeInsets.all(30), // Dialog içeriğine padding ekledik
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(baslikController, 'Başlık'),
                const SizedBox(height: 10), // Alanlar arasında boşluk
                _buildTextField(aciklamaController, 'Açıklama', maxLines: 3),
                const SizedBox(height: 10),
                _buildTextField(fiyatController, 'Fiyat',
                    keyboardType: TextInputType.number),
                const SizedBox(height: 10),
                _buildTextField(genislikController, 'Genişlik',
                    keyboardType: TextInputType.number),
                const SizedBox(height: 10),
                _buildTextField(yukseklikController, 'Yükseklik',
                    keyboardType: TextInputType.number),
                const SizedBox(height: 10),
                _buildTextField(miktarController, 'Miktar',
                    keyboardType: TextInputType.number),
                const SizedBox(height: 10),
                _buildDropdown(
                    'İl',
                    selectedIl,
                    cities.map((city) => city['name'].toString()).toList(),
                    (value) => setState(() {
                          selectedIl = value!;
                        })),
                const SizedBox(height: 10),
                _buildDropdown(
                    'İlçe',
                    selectedIlce,
                    districts
                        .map((district) => district['name'].toString())
                        .toList(),
                    (value) => selectedIlce = value!),
                const SizedBox(height: 10),
                _buildDropdown(
                    'Üretici',
                    selectedUretici,
                    AppConstants.manufacturers,
                    (value) => selectedUretici = value!),
                const SizedBox(height: 10),
                _buildDropdown('Renk', selectedRenk, AppConstants.colorOptions,
                    (value) => selectedRenk = value!),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'İptal',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orangeAccent,
                  fontSize: 16,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                final updatedData = {
                  'baslik': baslikController.text,
                  'aciklama': aciklamaController.text,
                  'fiyat': double.parse(fiyatController.text),
                  'genislik': double.parse(genislikController.text),
                  'yukseklik': double.parse(yukseklikController.text),
                  'miktar': int.parse(miktarController.text),
                  'il': selectedIl,
                  'ilce': selectedIlce,
                  'uretici': selectedUretici,
                  'renk': selectedRenk,
                };

                await FirebaseFirestore.instance
                    .collection(koleksiyon!)
                    .doc(widget.ilanId)
                    .update(updatedData);

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('İlan başarıyla güncellendi',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                );
              },
              child: const Text(
                'Kaydet',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orangeAccent,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
