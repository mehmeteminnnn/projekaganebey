import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addToCart(BuildContext context, String userId, String ilanId, int miktar) async {
  final userRef = _firestore.collection('users').doc(userId);

  try {
    final userDoc = await userRef.get();

    if (userDoc.exists) {
      // Kullanıcı mevcutsa, sepeti al
      var sepetim = List<Map<String, dynamic>>.from(userDoc['sepetim'] ?? []);

      // Sepet zaten mevcutsa, ürünü bul
      var existingProduct = sepetim.firstWhere(
        (item) => item['id'] == ilanId,
        orElse: () => {},
      );

      if (existingProduct.isEmpty) {
        // Ürün sepette yok, yeni ürün ekle
        sepetim.add({'id': ilanId, 'miktar': miktar});
      } else {
        // Ürün sepette mevcut, miktarı arttır
        existingProduct['miktar'] += miktar;
      }

      // Sepet güncelle
      await userRef.update({
        'sepetim': sepetim,
      });
    } else {
      // Kullanıcı dokümanı yoksa oluştur ve sepete ekle
      await userRef.set({
        'sepetim': [{'id': ilanId, 'miktar': miktar}],
      });
    }

    // İşlem başarılı olduğunda mesaj göster
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ürün sepetinize başarıyla eklendi!')),
    );
  } catch (e) {
    // Hata durumunda mesaj göster
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sepete eklerken bir hata oluştu: $e')),
    );
  }
}


  Future<bool> isFavorited(String userId, String ilanId) async {
    final userRef = _firestore.collection('users').doc(userId);

    try {
      final userDoc = await userRef.get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final favorilerim = List<String>.from(userData['favorilerim'] ?? []);
        return favorilerim.contains(ilanId);
      }
      return false;
    } catch (e) {
      throw Exception('Favori kontrolü sırasında hata oluştu: $e');
    }
  }
}
