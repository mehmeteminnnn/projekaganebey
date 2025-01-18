import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:projekaganebey/models/ilan_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //final FirebaseStorage _storage = FirebaseStorage.instance;
  final String adminId = 'CK6bCpvOHKMtACNj8SoZ';

  // İlan ekleme
  Future<void> addIlan(IlanModel ilan) async {
    await _firestore.collection('ilanlar').add(ilan.toMap());
  }

  // İlanları listeleme
  Future<List<IlanModel>> fetchIlanlar() async {
    QuerySnapshot query = await _firestore.collection('ilanlar').get();

    return query.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return IlanModel.fromMap(data, doc.id);
    }).toList();
  }

  Future<List<IlanModel>> fetchSimilarIlanlar(String ilanId) async {
    try {
      // İlanın kategorisini bul
      DocumentSnapshot ilanSnapshot =
          await _firestore.collection('ilanlar').doc(ilanId).get();

      if (!ilanSnapshot.exists) {
        throw Exception('İlan bulunamadı');
      }

      // İlanın kategorisini al
      String? kategori = ilanSnapshot['kategori'];

      if (kategori == null || kategori.isEmpty) {
        throw Exception('İlanın kategorisi bulunamadı');
      }

      // Aynı kategorideki ilanları getir, ancak aynı ilan ID'sini hariç tut
      QuerySnapshot snapshot = await _firestore
          .collection('ilanlar')
          .where('kategori', isEqualTo: kategori)
          .where(FieldPath.documentId, isNotEqualTo: ilanId)
          .get();

      return snapshot.docs
          .map((doc) =>
              IlanModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      debugPrint('Hata: $e');
      rethrow;
    }
  }

  // Kategoriye göre ilanları getirme
  Future<List<IlanModel>> fetchIlanlarByCategory(String? category) async {
    QuerySnapshot snapshot;

    if (category == null || category.isEmpty) {
      snapshot = await _firestore.collection('ilanlar').get();
    } else {
      snapshot = await _firestore
          .collection('ilanlar')
          .where('kategori', isEqualTo: category)
          .get();
    }

    return snapshot.docs
        .map((doc) =>
            IlanModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<List<IlanModel>> searchIlanlar(String query) async {
    final collection = FirebaseFirestore.instance.collection('ilanlar');
    final results = await collection
        .where('baslik', isGreaterThanOrEqualTo: query)
        .where('baslik', isLessThanOrEqualTo: '$query\uf8ff')
        .get();
    debugPrint('Arama sonuçları: $results');
    // Gelen dökümanları IlanModel'e dönüştür
    return results.docs.map((doc) {
      return IlanModel.fromMap(doc.data(), doc.id);
    }).toList();
  }

  // Filtrelere göre ilanları getirme
  Future<List<Map<String, dynamic>>> getFilteredAds(
      Map<String, dynamic> filters) async {
    Query query = _firestore.collection('ilanlar');

    if (filters['il'] != null) {
      query = query.where('il', isEqualTo: filters['il']);
    }
    if (filters['ilce'] != null) {
      query = query.where('ilce', isEqualTo: filters['ilce']);
    }
    if (filters['manufacturers'] != null &&
        filters['manufacturers'].isNotEmpty) {
      query = query.where('uretici', whereIn: filters['manufacturers']);
    }
    if (filters['fiyat'] != null &&
        filters['fiyat']['min'] != null &&
        filters['fiyat']['max'] != null) {
      query =
          query.where('fiyat', isGreaterThanOrEqualTo: filters['fiyat']['min']);
      query =
          query.where('fiyat', isLessThanOrEqualTo: filters['fiyat']['max']);
    }
    if (filters['selectedColor'] != null) {
      query = query.where('renk', isEqualTo: filters['selectedColor']);
    }

    QuerySnapshot snapshot = await query.get();
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  // Belirli bir listeye göre ilanları getirme
  Future<List<IlanModel>> fetchIlanlarByIdList(List<String> ilanIdList) async {
    if (ilanIdList.isEmpty) {
      return []; // Liste boşsa boş bir liste döndür
    }

    QuerySnapshot snapshot = await _firestore
        .collection('ilanlar')
        .where(FieldPath.documentId, whereIn: ilanIdList)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return IlanModel.fromMap(data, doc.id);
    }).toList();
  }

  Future<List<IlanModel>> searchIlanlarByTitle(String query) async {
    // Firestore'dan ilanları çekiyoruz (bu arama henüz harf duyarsız değil)
    final snapshot = await FirebaseFirestore.instance
        .collection('ilanlar')
        .get(); // 'baslik' ile ilgili herhangi bir filtreleme yapılmaz

    // Arama terimini küçük harfe çeviriyoruz
    String searchQuery = query.toLowerCase();

    // Veritabanından gelen veriyi filtreliyoruz
    final filteredData = snapshot.docs.where((doc) {
      // Başlıkları küçük harfe çevirerek karşılaştırıyoruz
      String title = doc['baslik'].toLowerCase();
      return title.contains(searchQuery);
    }).toList();

    // Filtrelenmiş verileri IlanModel'e dönüştürüyoruz
    return filteredData
        .map((doc) => IlanModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Toplam kullanıcı sayısını al
  Future<int> getTotalUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.size; // Kullanıcı sayısını döner
    } catch (e) {
      print("Hata: $e");
      return 0;
    }
  }

  // Toplam ilan sayısını al
  Future<int> getTotalAds() async {
    try {
      final snapshot = await _firestore.collection('ilanlar').get();
      return snapshot.size; // İlan sayısını döner
    } catch (e) {
      print("Hata: $e");
      return 0;
    }
  }

  // Bannerları listele
  Future<List<String>> getBanners() async {
    try {
      final ListResult banners =
          await FirebaseStorage.instance.ref('banners').listAll();
      List<String> bannerUrls = [];
      for (var item in banners.items) {
        final url = await item.getDownloadURL();
        bannerUrls.add(url);
      }
      return bannerUrls;
    } catch (e) {
      print("Hata: $e");
      return [];
    }
  }

  // Bannerı sil
  Future<void> deleteBanner(String bannerName) async {
    try {
      // Firestore'dan banner bilgilerini al
      final bannerSnapshot = await FirebaseFirestore.instance
          .collection('banners')
          .where('name', isEqualTo: bannerName)
          .get();

      // Eğer banner mevcutsa, Firestore'dan sil
      if (bannerSnapshot.docs.isNotEmpty) {
        for (var doc in bannerSnapshot.docs) {
          await doc.reference.delete();
        }
      } else {
        print("Banner Firestore'da bulunamadı: $bannerName");
      }

      // Firebase Storage'dan bannerı sil
      final ref = FirebaseStorage.instance.ref('banners/$bannerName');
      await ref.delete();
      debugPrint('Banner başarıyla silindi: $bannerName');
    } catch (e) {
      print("Hata: $e");
      throw Exception('Banner silinirken hata: $e');
    }
  }

  // Bildirim gönder
  Future<void> sendNotification(String title, String body) async {
    await _firestore.collection('notifications').add({
      'title': title,
      'body': body,
      'timestamp': FieldValue.serverTimestamp(),
    });
    // Burada ayrıca FCM entegrasyonu yapılabilir.
  }

  Future<void> addBanner(String bannerName, String bannerUrl) async {
    try {
      await FirebaseFirestore.instance.collection('banners').add({
        'name': bannerName,
        'url': bannerUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Banner eklenirken hata: $e');
    }
  }

  Future<void> updateAdminInfo(String username, String password) async {
    await _firestore.collection('admin').doc(adminId).set({
      'username': username,
      'password': password,
    });
  }

  Future<Map<String, dynamic>> getAdminInfo() async {
    DocumentSnapshot snapshot =
        await _firestore.collection('admin').doc(adminId).get();
    return snapshot.data() as Map<String, dynamic>;
  }
}
