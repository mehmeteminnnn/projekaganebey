import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth için referans
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _titleController =
      TextEditingController(); // Ürün Başlığı için Controller

  Future<void> saveIlanToFirestore() async {
    try {
      // Oturum açan kullanıcının UID'sini al
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception("Kullanıcı oturumu açık değil!");
      }

      String userId = user.uid;

      // TextField'den alınan açıklama ve başlık metinlerini IlanModel'e ekleyelim
      String description = _descriptionController.text;
      String title = _titleController.text;

      widget.ilan.aciklama = description;
      widget.ilan.baslik = title;
      widget.ilan.id = userId; // Kullanıcı UID'sini IlanModel'e ekle

      // Firestore koleksiyonuna yeni ilan ekleme
      await _firestore.collection('ilanlar').add(widget.ilan.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('İlan başarıyla kaydedildi!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailPage(
            images: widget.images,
          ),
        ),
      );
    } catch (e) {
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
}
