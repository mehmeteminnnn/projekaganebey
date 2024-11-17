import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projekaganebey/ilan_hazir.dart';

import 'package:projekaganebey/models/ilan.dart';

class ProductPage extends StatefulWidget {
  final List<XFile?> images;
  final IlanModel ilan;
  ProductPage({required this.images, required this.ilan});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> saveIlanToFirestore() async {
    try {
      // TextField'den alınan açıklama metnini IlanModel'e ekleyelim
      String description = _descriptionController.text;

      widget.ilan.aciklama = description;

      // Firestore koleksiyonuna yeni ilan ekleme
      await _firestore.collection('ilanlar').add(widget.ilan.toMap());

      // Kaydın başarılı olduğunu gösteren bir mesaj
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('İlan başarıyla kaydedildi!')),
      );

      // Başka bir sayfaya yönlendirme (örneğin ilanlar sayfası)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailPage(
              images: widget
                  .images), // IlanlarPage yerine uygun sayfa adını kullanın
        ),
      );
    } catch (e) {
      // Hata durumu
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
                  Text("Yüklenen Fotoğraflar",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 80, // Fotoğrafların listeleneceği alanın yüksekliği
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

              // Seçilenler Bölümü
              Text(
                'Seçilenler',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 4),
              Text(
                'PANEL > Beypan > 72 X 78, Yatay > Doğal Ahşap',
                style: TextStyle(color: Colors.grey[700]),
              ),
              Divider(thickness: 1, color: Colors.grey[300]),

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
                  'Küçükçekmece, İstanbul',
                  style: TextStyle(color: Colors.black, fontSize: 14),
                ),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Konum seçme işlemi
                },
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
                    '1.356 TL',
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
}
