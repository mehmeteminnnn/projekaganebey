import 'package:flutter/material.dart';
import 'package:projekaganebey/services/firestore_services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class BannerPage extends StatefulWidget {
  @override
  _BannerPageState createState() => _BannerPageState();
}

class _BannerPageState extends State<BannerPage> {
  final FirestoreService _firestoreService = FirestoreService();
  List<String> banners = [];
  bool isLoading = false;

  Widget _buildBannerCard(String bannerUrl, int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 400 / 60,
              child: Image.network(
                bannerUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(child: CircularProgressIndicator());
                },
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteDialog(bannerUrl),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(String bannerUrl) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Banner\'ı Sil'),
          content: Text('Bu banner\'ı silmek istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              child: Text('İptal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Sil', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteBanner(bannerUrl);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _addBanner(File imageFile) async {
    setState(() {
      isLoading = true;
    });

    try {
      final bannerName = imageFile.path.split('/').last;
      final storageRef =
          FirebaseStorage.instance.ref().child('banners/$bannerName');
      await storageRef.putFile(imageFile);
      final bannerUrl = await storageRef.getDownloadURL();
      await _firestoreService.addBanner(bannerName, bannerUrl);
      await _loadBanners();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Banner eklenirken bir hata oluştu: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showAddBannerDialog() {
    File? imageFile;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Yeni Banner Ekle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () async {
                  final pickedFile = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    imageFile = File(pickedFile.path);
                  }
                },
                child: Text('Resim Seç'),
              ),
              if (imageFile != null) Text('Seçilen Resim: ${imageFile!.path}'),
            ],
          ),
          actions: [
            TextButton(
              child: Text('İptal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Ekle'),
              onPressed: () {
                Navigator.of(context).pop();
                if (imageFile != null) {
                  _addBanner(imageFile!);
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadBanners();
  }

  Future<void> _loadBanners() async {
    setState(() {
      isLoading = true;
    });

    try {
      final loadedBanners = await _firestoreService.getBanners();
      setState(() {
        banners = loadedBanners;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bannerlar yüklenirken bir hata oluştu: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteBanner(String bannerUrl) async {
    setState(() {
      isLoading = true;
    });

    try {
      final decodedUrl = Uri.decodeFull(bannerUrl);
      final bannerName = decodedUrl.split('/').last.split('?').first;
      await _firestoreService.deleteBanner(bannerName);
      final storageRef =
          FirebaseStorage.instance.ref().child('banners/$bannerName');

      try {
        await storageRef.getDownloadURL();
        await storageRef.delete();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Silinecek dosya mevcut değil: $bannerName')),
        );
      }

      await _loadBanners();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Banner silinirken bir hata oluştu: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Banner Yönetimi",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : banners.isEmpty
              ? Center(
                  child: Text(
                    'Henüz banner eklenmemiş',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : Padding(
                  padding: EdgeInsets.all(16),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          MediaQuery.of(context).size.width > 600 ? 2 : 1,
                      childAspectRatio: 400 / 70,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: banners.length,
                    itemBuilder: (context, index) =>
                        _buildBannerCard(banners[index], index),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddBannerDialog();
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
