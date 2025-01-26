import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

void addRandomMdfLamDocuments() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Sabit veriler
  const List<String> manufacturers = [
    'Yıldız Entegre',
    'Kastamonu Entegre',
    'Çamsan Entegre',
    'Starwood',
    'Yıldız Sunta MDF',
    'AGT',
    'Teverpan',
    'Çamsan Poyraz',
    'Vezirağaç',
    'SFC (Kronospan)',
    'Beypan',
    'SBS',
    'Balkanlar MDF',
    'Seloit',
    "Diğer"
  ];

  const List<String> colorOptions = [
    'Doğal Ahşap',
    'Beyaz ve Açık',
    'Koyu Renkler',
    'Metalik ve Beton Efekti',
    'Canlı ve Renkli'
  ];

  // Random nesnesi
  final Random random = Random();

  // Rastgele veri oluştur ve Firestore'a ekle
  for (int i = 0; i < 15; i++) {
    Map<String, dynamic> data = {
      "aciklama": "Rastgele açıklama ${i + 1}",
      "baslik": "SUnta ${i + 1}",
      "desenYonu": null,
      "fiyat": random.nextInt(10000) +
          1000, // 1000 ile 11000 arasında rastgele fiyat
      "genislik":
          random.nextInt(100) + 10, // 10 ile 110 arasında rastgele genişlik
      "il": "MANİSA",
      "ilce": "TURGUTLU",
      "kategori": "PANEL",
      "mahalle": "Mahalle Yok",
      "miktar": random.nextInt(20) + 1, // 1 ile 20 arasında rastgele miktar
      "olusturanKullaniciId":
          "nesVqurnA3QMPY6d69eCHQyYmka2", // Sabit kullanıcı ID'si
      "olusturulmaTarihi": Timestamp.now(),
      "renk": colorOptions[
          random.nextInt(colorOptions.length)], // Rastgele renk seçimi
      "resimler": [
        "https://firebasestorage.googleapis.com/v0/b/kaganbey.firebasestorage.app/o/ilanlar%2FzUkMIDueNOYxxfg3cOk5g4zWQyT2-1732631352543.jpg?alt=media&token=19b1779b-6ffa-4076-8dad-e78084484fa3"
      ],
      "uretici": manufacturers[
          random.nextInt(manufacturers.length)], // Rastgele üretici seçimi
      "yukseklik":
          random.nextInt(50) + 10 // 10 ile 60 arasında rastgele yükseklik
    };

    try {
      await firestore.collection('sunta').add(data);
      print("Belge ${i + 1} başarıyla eklendi!");
    } catch (e) {
      print("Hata oluştu: $e");
    }
  }
}
