import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projekaganebey/ilan_ozellikleri.dart';
import 'package:projekaganebey/models/ilan.dart';

class IlanVerPage extends StatefulWidget {
  final String? id;
  const IlanVerPage({Key? key, this.id}) : super(key: key);
  @override
  _IlanVerPageState createState() => _IlanVerPageState();
}

class _IlanVerPageState extends State<IlanVerPage> {
  final List<XFile?> _images = [];
  final ImagePicker _picker = ImagePicker();
  final List<String> _imageUrls = []; // Yüklenen resimlerin URL'leri

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _images.add(pickedFile);
      });
    }
  }

  Future<void> _uploadImages() async {
    final String? uid = widget.id; // FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      print("Kullanıcı oturum açmamış.");
      return;
    }

    for (var image in _images) {
      if (image != null) {
        File file = File(image.path);
        String fileName = '$uid-${DateTime.now().millisecondsSinceEpoch}.jpg';
        Reference storageRef =
            FirebaseStorage.instance.ref().child('ilanlar/$fileName');
        UploadTask uploadTask = storageRef.putFile(file);

        final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();

        // URL eklenmeden önce print ile kontrol edelim
        print("Yüklenen resmin URL'si: $downloadUrl");
        _imageUrls.add(downloadUrl);
      }
    }
    // Yüklenen URL'leri kontrol etmek için bir print
    print("Yüklenen resimlerin URL'leri: $_imageUrls");
  }

  Future<void> _onContinue() async {
    if (_images.isNotEmpty) {
      // Resimleri yükle
      await _uploadImages(); // Resimler yüklendikten sonra devam et

      // Yüklenen resimlerin URL'lerini kontrol et
      if (_imageUrls.isEmpty) {
        print("Resimler yüklenmedi.");
        return;
      }

      // İlan modelini oluştur
      IlanModel ilan = IlanModel(
        resimler: _imageUrls, // Yüklenen URL'ler doğru şekilde eklenmiş olmalı
        // Diğer alanları burada doldurabilirsiniz.
      );

      // Yüklenen resimler varsa, ilan sayfasına yönlendirme işlemi
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IlanOzellikleriPage(
            ilan: ilan,
            images: _images,
          ),
        ),
      );
    } else {
      print("Resim yüklenmemiş.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Fotoğraf",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        if (index < _images.length) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: FileImage(
                                    File(_images[index]!.path),
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30.0),
            child: Column(
              children: [
                Icon(Icons.camera_alt, size: 64, color: Colors.grey),
                SizedBox(height: 10),
                Text(
                  'Ürün fotoğraflarını yükle',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Bir sonraki adıma geçmek için en az 1 fotoğraf yükleyin.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _images.isNotEmpty ? _onContinue : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _images.isNotEmpty ? Colors.orange : Colors.grey,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text('Devam et', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
