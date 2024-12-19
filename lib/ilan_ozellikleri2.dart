import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projekaganebey/ilan_detay.dart';
import 'package:projekaganebey/ilan_hazir.dart';
import 'package:projekaganebey/models/ilan.dart';
import 'package:turkish/turkish.dart';

class ProductPage extends StatefulWidget {
  final List<XFile?> images;
  final IlanModel ilan;
  final String? id;

  ProductPage({required this.images, required this.ilan, this.id});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final List<String> _imageUrls = []; // Yüklenen resimlerin URL'leri
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  /* final FirebaseAuth _auth =
      FirebaseAuth.instance; // Firebase Auth için referans*/
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _titleController =
      TextEditingController(); // Ürün Başlığı için Controller
  String? selectedDistrictId;
  //String? enteredNeighborhood;
  String? selectedCityId;

  List<dynamic> cities = [];
  List<dynamic> districts = [];
  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  Future<void> _uploadImages() async {
    final String? uid = widget.id; // User ID'yi burada alabilirsiniz

    for (var image in widget.images) {
      if (image != null) {
        File file = File(image.path);
        String fileName = '$uid-${DateTime.now().millisecondsSinceEpoch}.jpg';
        Reference storageRef =
            FirebaseStorage.instance.ref().child('ilanlar/$fileName');
        UploadTask uploadTask = storageRef.putFile(file);

        final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();

        // URL'yi ekleyelim
        _imageUrls.add(downloadUrl);
      }
    }
  }

  Future<void> _loadCities() async {
    // İl JSON dosyasını oku
    String cityJson = await rootBundle.loadString('assets/il.json');
    List<Map<String, dynamic>> cityList =
        List<Map<String, dynamic>>.from(jsonDecode(cityJson));

    // Şehirleri alfabetik sıraya göre sıralayın
    cityList.sort((a, b) => turkish.comparator(a['name'], b['name']));

    setState(() {
      cities = cityList;
    });
  }

  Future<void> _updateDistricts() async {
    // İlçe JSON dosyasını oku
    String districtJson = await rootBundle.loadString('assets/ilce.json');
    List<dynamic> allDistricts = jsonDecode(districtJson);

    // Seçili şehre ait ilçeleri filtrele
    setState(() {
      districts = allDistricts
          .where((district) => district['il_id'] == selectedCityId)
          .toList();
    });
  }

  Future<void> saveIlanToFirestore() async {
    try {
      String? userId = widget.id;
// Resimleri yüklemeden önce bekleyin
      await _uploadImages(); // Resimler yüklendikten sonra işlemi devam ettirin
      // TextField'den alınan açıklama ve başlık metinlerini IlanModel'e ekleyelim
      String description = _descriptionController.text;
      String title = _titleController.text;
      widget.ilan.il = cities.firstWhere(
          (city) => city['id'].toString() == selectedCityId)['name'];
      widget.ilan.ilce = districts.firstWhere((district) =>
          district['id'].toString() == selectedDistrictId)['name'];
      widget.ilan.aciklama = description;
      widget.ilan.baslik = title;
      widget.ilan.olusturanKullaniciId =
          userId; // Kullanıcı UID'sini IlanModel'e ekle
      widget.ilan.resimler = _imageUrls; // Resim URL'lerini IlanModel'e ekle

      // Yeni ilanı 'ilanlar' koleksiyonuna ekle ve ID'sini al
      DocumentReference ilanDocRef =
          await _firestore.collection('ilanlar').add(widget.ilan.toMap());
      String ilanId = ilanDocRef.id;

      // Kullanıcının 'users' koleksiyonundaki dökümanını güncelle
      await _firestore.collection('users').doc(userId).set({
        'ilanlar': FieldValue.arrayUnion([ilanId])
      }, SetOptions(merge: true));

      // Kullanıcıya başarı mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('İlan başarıyla kaydedildi!')),
      );

      // İlan detay sayfasına yönlendir
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => IlanDetayPage(ilanId: ilanId),
        ),
      );
    } catch (e) {
      // Hata durumunda kullanıcıya mesaj göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bir hata oluştu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'İlan Bilgileri',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ürün Fotoğrafları Bölümü
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Yüklenen Fotoğraflar",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.images.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image:
                                    FileImage(File(widget.images[index]!.path)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              SizedBox(height: 16),

              // Seçilenler Bölümü
              Text(
                'Seçilenler',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 4),
              Text(
                '${widget.ilan.kategori} > ${widget.ilan.uretici} > [${widget.ilan.yukseklik?.toInt()}][${widget.ilan.genislik?.toInt()}]*${widget.ilan.miktar} > ${widget.ilan.renk}',
                style: TextStyle(color: Colors.grey[700]),
              ),
              Divider(thickness: 1, color: Colors.grey[300]),

              // Ürün Başlığı Bölümü
              Text(
                'Ürün Başlığı',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _titleController,
                maxLength: 50,
                decoration: InputDecoration(
                  hintText: 'Ürün başlığını girin',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
              ),
              SizedBox(height: 16),

              // Ürün Açıklaması Bölümü
              Text(
                'Ürün Açıklaması',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                maxLength: 140,
                decoration: InputDecoration(
                  hintText: 'Açıklama girin',
                  border: OutlineInputBorder(),
                  counterText: '0/140',
                ),
              ),
              SizedBox(height: 16),

              // Konum Bölümü
              Text(
                'Konum',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 4),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  selectedCityId != null && selectedDistrictId != null
                      ? '${districts.firstWhere((d) => d['id'] == selectedDistrictId)['name']}, ${cities.firstWhere((c) => c['id'] == selectedCityId)['name']}'
                      : 'Şehir ve İlçe Seçin',
                  style: TextStyle(color: Colors.black, fontSize: 14),
                ),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _showCityDistrictSelector, // Modal'ı açan fonksiyon
              ),

              Divider(thickness: 1, color: Colors.grey[300]),

              // Fiyat Bilgisi Bölümü
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Birim Adet Fiyatı:',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  Text(
                    '${widget.ilan.fiyat} ₺',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Devam Et Butonu
              Center(
                child: ElevatedButton(
                  onPressed: saveIlanToFirestore, // Firestore'a kaydetme işlemi
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 100, vertical: 12),
                  ),
                  child: Text(
                    'Devam et',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCityDistrictSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık
                  Text(
                    'Konum Seçin',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),

                  // Şehir Dropdown
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Şehir Seçin',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedCityId,
                    onChanged: (value) {
                      setState(() {
                        selectedCityId = value;
                        selectedDistrictId = null; // İlçe seçimini sıfırla
                        _updateDistricts(); // İlçeleri güncelle
                      });
                    },
                    items: cities.map((city) {
                      return DropdownMenuItem<String>(
                        value: city['id'].toString(),
                        child: Text(city['name']),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16),

                  // İlçe Dropdown
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'İlçe Seçin',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedDistrictId,
                    onChanged: (value) {
                      setState(() {
                        selectedDistrictId = value;
                      });
                    },
                    items: districts.map((district) {
                      return DropdownMenuItem<String>(
                        value: district['id'].toString(),
                        child: Text(district['name']),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16),

                  // Onaylama Butonu
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (selectedCityId != null &&
                            selectedDistrictId != null) {
                          Navigator.pop(context); // Modal'ı kapat
                          setState(() {});
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Lütfen hem şehir hem de ilçe seçin.'),
                            ),
                          );
                        }
                      },
                      child: Text('Onayla'),
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 100, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
