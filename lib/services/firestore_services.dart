import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projekaganebey/models/ilan.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // İlan ekleme
  Future<void> addIlan(IlanModel ilan) async {
    await _firestore.collection('ilanlar').add(ilan.toMap());
  }

  // İlanları listeleme
  Future<List<IlanModel>> fetchIlanlar() async {
    QuerySnapshot query = await _firestore.collection('ilanlar').get();

    // Her bir döküman için dönüşüm işlemi
    return query.docs.map((doc) {
      final data = doc.data() as Map<String,
          dynamic>; // Veriyi doğru şekilde Map<String, dynamic> türüne dönüştürüyoruz
      return IlanModel.fromMap(data, doc.id); // fromMap sırasını düzelttik
    }).toList();
  }

  Future<List<IlanModel>> fetchIlanlarByCategory(String? category) async {
    QuerySnapshot snapshot;

    if (category == null || category.isEmpty) {
      // Eğer kategori seçilmemişse veya null ise, tüm ilanları getir
      snapshot = await _firestore.collection('ilanlar').get();
    } else {
      // Kategori seçilmişse, o kategoriye göre ilanları filtrele
      snapshot = await _firestore
          .collection('ilanlar')
          .where('kategori', isEqualTo: category)
          .get();
    }

    // Verileri çekerken 'fromMap' metodunu kullanarak liste oluşturuyoruz.
    return snapshot.docs
        .map((doc) => IlanModel.fromMap(
            doc.data() as Map<String, dynamic>, doc.id)) // id'yi de dahil et
        .toList();
  }

  Future<List<Map<String, dynamic>>> getFilteredAds(
      Map<String, dynamic> filters) async {
    Query query = _firestore.collection('ilanlar');

    if (filters['selectedIl'] != null) {
      query = query.where('il', isEqualTo: filters['selectedIl']);
    }
    if (filters['selectedIlce'] != null) {
      query = query.where('ilce', isEqualTo: filters['selectedIlce']);
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
}
