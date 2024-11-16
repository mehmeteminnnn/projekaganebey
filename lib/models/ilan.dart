import 'package:cloud_firestore/cloud_firestore.dart';

class Ilan {
  final String id; // İlanın benzersiz ID'si
  final String baslik; // İlan başlığı
  final String aciklama; // İlan açıklaması
  final String kategori; // İlan kategorisi
  final String il; // Şehir
  final String ilce; // İlçe
  final String mahalle; // Mahalle
  final String olusturanKullaniciId; // İlanı oluşturan kullanıcının ID'si
  final DateTime olusturulmaTarihi; // İlanın oluşturulma tarihi
  final double fiyat; // İlanın fiyatı
  final List<String> resimler; // İlan için resim URL'leri
  final String uretici; // Üretici firma/marka
  final double yukseklik; // Ürün yüksekliği
  final double genislik; // Ürün genişliği
  final int miktar; // Ürün miktarı
  final String? desenYonu; // Desen yönü (nullable)
  final String renk; // Ürünün rengi

  Ilan({
    required this.id,
    required this.baslik,
    required this.aciklama,
    required this.kategori,
    required this.il,
    required this.ilce,
    required this.mahalle,
    required this.olusturanKullaniciId,
    required this.olusturulmaTarihi,
    required this.fiyat,
    required this.resimler,
    required this.uretici,
    required this.yukseklik,
    required this.genislik,
    required this.miktar,
    this.desenYonu, // nullable alan
    required this.renk,
  });

  // Firestore'dan veri çekerken kullanılan `fromMap` metodu
  factory Ilan.fromMap(String id, Map<String, dynamic> map) {
    return Ilan(
      id: id,
      baslik: map['baslik'] ?? '',
      aciklama: map['aciklama'] ?? '',
      kategori: map['kategori'] ?? '',
      il: map['il'] ?? '',
      ilce: map['ilce'] ?? '',
      mahalle: map['mahalle'] ?? '',
      olusturanKullaniciId: map['olusturanKullaniciId'] ?? '',
      olusturulmaTarihi: (map['olusturulmaTarihi'] as Timestamp).toDate(),
      fiyat: map['fiyat']?.toDouble() ?? 0.0,
      resimler: List<String>.from(map['resimler'] ?? []),
      uretici: map['uretici'] ?? '',
      yukseklik: map['yukseklik']?.toDouble() ?? 0.0,
      genislik: map['genislik']?.toDouble() ?? 0.0,
      miktar: map['miktar']?.toInt() ?? 0,
      desenYonu: map['desenYonu'], // nullable olduğu için doğrudan atanıyor
      renk: map['renk'] ?? '',
    );
  }

  // Firestore'a veri yazarken kullanılan `toMap` metodu
  Map<String, dynamic> toMap() {
    return {
      'baslik': baslik,
      'aciklama': aciklama,
      'kategori': kategori,
      'il': il,
      'ilce': ilce,
      'mahalle': mahalle,
      'olusturanKullaniciId': olusturanKullaniciId,
      'olusturulmaTarihi': olusturulmaTarihi,
      'fiyat': fiyat,
      'resimler': resimler,
      'uretici': uretici,
      'yukseklik': yukseklik,
      'genislik': genislik,
      'miktar': miktar,
      'desenYonu': desenYonu, // nullable olduğu için doğrudan atanıyor
      'renk': renk,
    };
  }
}
