import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addToCart(BuildContext context, String userId, String ilanId) async {
  final userRef = _firestore.collection('users').doc(userId);

  try {
    final userDoc = await userRef.get();

    if (userDoc.exists) {
      // Kullanıcı mevcutsa sepete ekle
      await userRef.update({
        'sepetim': FieldValue.arrayUnion([ilanId]),
      });
    } else {
      // Kullanıcı dokümanı yoksa oluştur ve sepete ekle
      await userRef.set({
        'sepetim': [ilanId],
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
