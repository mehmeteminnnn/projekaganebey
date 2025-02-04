import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:Depot/models/ilan_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //final FirebaseStorage _storage = FirebaseStorage.instance;
  final String adminId = 'CK6bCpvOHKMtACNj8SoZ';

  // İlan ekleme
  Future<void> addIlan(IlanModel ilan) async {
    await _firestore.collection('ilanlar').add(ilan.toMap());
  }

  /* // İlanları listeleme
  Future<List<IlanModel>> fetchIlanlar() async {
    QuerySnapshot query = await _firestore.collection('ilanlar').get();

    return query.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return IlanModel.fromMap(data, doc.id);
    }).toList();
  }*/

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

  Future<List<IlanModel>> searchIlanlar(String query) async {
    List<String> koleksiyonlar = ['mdf_lam', 'sunta', 'osb', 'panel'];
    List<IlanModel> tumSonuclar = [];

    for (String koleksiyon in koleksiyonlar) {
      final collection = FirebaseFirestore.instance.collection(koleksiyon);
      final results = await collection
          .where('baslik', isGreaterThanOrEqualTo: query)
          .where('baslik', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      debugPrint(
          'Arama sonuçları (${koleksiyon}): ${results.docs.length} bulundu.');

      tumSonuclar.addAll(results.docs.map((doc) {
        return IlanModel.fromMap(doc.data(), doc.id);
      }));
    }

    return tumSonuclar;
  }

  Future<List<Map<String, dynamic>>> getFilteredAds(
      Map<String, dynamic> filters) async {
    List<String> koleksiyonlar = ['mdf_lam', 'sunta', 'osb', 'panel'];
    List<Map<String, dynamic>> tumIlanlar = [];

    for (String koleksiyon in koleksiyonlar) {
      Query query = _firestore.collection(koleksiyon);

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
        query = query.where('fiyat',
            isGreaterThanOrEqualTo: filters['fiyat']['min']);
        query =
            query.where('fiyat', isLessThanOrEqualTo: filters['fiyat']['max']);
      }
      if (filters['selectedColor'] != null) {
        query = query.where('renk', isEqualTo: filters['selectedColor']);
      }

      QuerySnapshot snapshot = await query.get();
      for (var doc in snapshot.docs) {
        Map<String, dynamic> ilanVerisi = doc.data() as Map<String, dynamic>;
        ilanVerisi['id'] = doc.id; // Doküman ID'sini ekliyoruz
        tumIlanlar.add(ilanVerisi);
      }
    }

    return tumIlanlar;
  }

  // Belirli bir listeye göre ilanları getirme
  Future<List<IlanModel>> fetchIlanlarByIdList(List<String> ilanIdList) async {
    if (ilanIdList.isEmpty) {
      return []; // Liste boşsa boş bir liste döndür
    }

    final List<String> collections = [
      'ilanlar',
      'mdf_lam',
      'osb_panel',
      'sunta'
    ];
    List<IlanModel> ilanlar = [];

    for (var collection in collections) {
      QuerySnapshot snapshot = await _firestore
          .collection(collection)
          .where(FieldPath.documentId, whereIn: ilanIdList)
          .get();

      ilanlar.addAll(snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return IlanModel.fromMap(data, doc.id);
      }));
    }

    return ilanlar;
  }

  Future<List<IlanModel>> searchIlanlarByTitle(String query) async {
    List<String> koleksiyonlar = ['mdf_lam', 'osb', 'panel', 'sunta'];
    List<IlanModel> tumIlanlar = [];

    String searchQuery = query.toLowerCase();

    for (String koleksiyon in koleksiyonlar) {
      final snapshot = await FirebaseFirestore.instance
          .collection(koleksiyon)
          .get(); // Tüm ilanları çekiyoruz

      final filteredData = snapshot.docs.where((doc) {
        String title = doc['baslik'].toLowerCase();
        return title.contains(searchQuery);
      }).toList();

      // Filtrelenmiş ilanları modele çevirerek listeye ekliyoruz
      tumIlanlar.addAll(
          filteredData.map((doc) => IlanModel.fromMap(doc.data(), doc.id)));
    }

    return tumIlanlar; // Tüm koleksiyonlardan gelen ilanları döndürüyoruz
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

  Future<int> getTotalAds() async {
    try {
      List<String> koleksiyonlar = ['mdf_lam', 'sunta', 'osb', 'panel'];
      int toplamIlan = 0;

      for (String koleksiyon in koleksiyonlar) {
        final snapshot = await _firestore.collection(koleksiyon).get();
        toplamIlan += snapshot.size; // Her koleksiyonun ilan sayısını ekliyoruz
      }

      return toplamIlan;
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

//bu kısım
  // İlan ID'sine göre kullanıcının telefon numarasını alma
  Future<String?> getUserPhoneByIlanId(String ilanId) async {
    try {
      List<String> koleksiyonlar = ['mdf_lam', 'osb', 'panel', 'sunta'];
      DocumentSnapshot? ilanSnapshot;

      // İlanın hangi koleksiyonda olduğunu bul
      for (String koleksiyon in koleksiyonlar) {
        ilanSnapshot =
            await _firestore.collection(koleksiyon).doc(ilanId).get();
        if (ilanSnapshot.exists) {
          break; // İlk bulduğu koleksiyonla devam et
        }
      }

      if (ilanSnapshot == null || !ilanSnapshot.exists) {
        throw Exception('İlan bulunamadı');
      }

      // İlanı oluşturan kullanıcının ID'sini al
      String? kullaniciId = ilanSnapshot['olusturanKullaniciId'];

      if (kullaniciId == null) {
        throw Exception('Kullanıcı ID bulunamadı');
      }

      // Kullanıcının telefon numarasını al
      DocumentSnapshot userSnapshot =
          await _firestore.collection('users').doc(kullaniciId).get();

      if (!userSnapshot.exists) {
        throw Exception('Kullanıcı bulunamadı');
      }

      return userSnapshot['phone'] as String?;
    } catch (e) {
      debugPrint('Hata: $e');
      return null;
    }
  }

// Koleksiyondaki belge sayısını al
  Future<int> getDocumentCount(String collectionName) async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection(collectionName).get();
      return snapshot.docs.length;
    } catch (e) {
      print("Error getting document count for $collectionName: $e");
      return 0;
    }
  }

  Future<int> getDocumentCountByProducer(
      String category, String producer) async {
    try {
      final snapshot = await _firestore
          .collection(category) // Örneğin "mdf" koleksiyonu
          .where('uretici', isEqualTo: producer)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error fetching document count for $producer in $category: $e');
      return 0;
    }
  }

  Future<List<IlanModel>> fetchAllIlanlar() async {
    // Koleksiyon isimlerini bir listeye koyuyoruz
    List<String> collections = ['mdf_lam', 'osb', 'panel', 'sunta'];
    List<IlanModel> allIlanlar = [];

    for (String collection in collections) {
      // Her koleksiyon için en fazla 10 belgeyi çekiyoruz
      QuerySnapshot snapshot =
          await _firestore.collection(collection).limit(10).get();

      // Her koleksiyondaki belgeleri IlanModel'e dönüştürüp listeye ekliyoruz
      allIlanlar.addAll(snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return IlanModel.fromMap(data, doc.id);
      }).toList());
    }

    return allIlanlar;
  }

// Kategori ve üreticiye göre ilanları getirme (Maksimum 10 ilan)
  Future<List<IlanModel>> fetchIlanlarByCategoryAndProducer(
      String? category, String? producer, bool hepsimi) async {
    if (category == null || category.isEmpty) {
      throw Exception('Kategori adı boş olamaz');
    }

    Query query =
        _firestore.collection(category); // Kategoriye göre koleksiyon seç

    if (!hepsimi && producer != null && producer.isNotEmpty) {
      query = query.where('uretici',
          isEqualTo: producer); // Üreticiye göre filtrele
    }

    QuerySnapshot snapshot = await query.limit(20).get(); // 10 ilan ile sınırla

    return snapshot.docs
        .map((doc) =>
            IlanModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<String?> getUserNameById(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        return userDoc.get('name') as String?;
      } else {
        return null; // Kullanıcı bulunamazsa null döndür
      }
    } catch (e) {
      print("Hata: $e");
      return null;
    }
  }

  // Random ilanları getir
  Future<List<IlanModel>> getRandomIlanlar(String collection, int limit) async {
    try {
      // Koleksiyondaki tüm ilanları al
      QuerySnapshot snapshot = await _firestore.collection(collection).get();

      // Dökümanları karıştır ve limit kadar al
      final docs = snapshot.docs..shuffle();
      final randomDocs = docs.take(limit).toList();

      // IlanModel listesine dönüştür
      return randomDocs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return IlanModel.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      print("Hata: $e");
      return [];
    }
  }
}
