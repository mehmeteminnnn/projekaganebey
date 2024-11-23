
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
        .map((doc) => IlanModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))  // id'yi de dahil et
        .toList();
}

}
