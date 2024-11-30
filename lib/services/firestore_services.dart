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

    return query.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return IlanModel.fromMap(data, doc.id);
    }).toList();
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
        .map((doc) => IlanModel.fromMap(
            doc.data() as Map<String, dynamic>, doc.id))
        .toList();
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
}
