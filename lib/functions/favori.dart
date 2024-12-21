import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Future<void> toggleFavori({
  required String userId,
  required String ilanID,
}) async {
  // Kullanıcıya ait favoriler array'ini al
  DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

  if (userDoc.exists) {
    List<dynamic> favorilerim = userDoc['favorilerim'] ?? [];

    // Eğer favorilerde mevcutsa, çıkar
    if (favorilerim.contains(ilanID)) {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'favorilerim': FieldValue.arrayRemove([ilanID]),
      });
      debugPrint('İlan favorilerden çıkarıldı');
    } 
    // Favorilerde değilse, ekle
    else {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'favorilerim': FieldValue.arrayUnion([ilanID]),
      });
      debugPrint('İlan favorilere eklendi');
    }
  }
}
