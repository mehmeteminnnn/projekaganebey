import 'package:cloud_firestore/cloud_firestore.dart';

class IlanModel {
  String? id; // İlanın benzersiz ID'si
  String? baslik; // İlan başlığı
  String? aciklama; // İlan açıklaması
  String? kategori; // İlan kategorisi
  String? il; // Şehir
  String? ilce; // İlçe
  String? mahalle; // Mahalle
  String? olusturanKullaniciId; // İlanı oluşturan kullanıcının ID'si
  DateTime? olusturulmaTarihi; // İlanın oluşturulma tarihi
  double? fiyat; // İlanın fiyatı
  List<String>? resimler; // İlan için resim URL'leri
  String? uretici; // Üretici firma/marka
  double? yukseklik; // Ürün yüksekliği
  double? en; // Ürün eni
  double? genislik; // Ürün genişliği
  int? miktar; // Ürün miktarı
  String? desenYonu; // Desen yönü (nullable)
  String? renk; // Ürünün rengi

  IlanModel({
    this.en = 0.0, // Varsayılan değer
    this.id,
    this.baslik = "Başlık Yok", // Varsayılan değer
    this.aciklama = "Açıklama Yok", // Varsayılan değer
    this.kategori = "Kategori Yok", // Varsayılan değer
    this.il = "İl Yok", // Varsayılan değer
    this.ilce = "İlçe Yok", // Varsayılan değer
    this.mahalle = "Mahalle Yok", // Varsayılan değer
    this.olusturanKullaniciId,
    this.olusturulmaTarihi,
    this.fiyat = 0.0, // Varsayılan değer
    this.resimler = const [], // Varsayılan değer
    this.uretici = "Üretici Yok", // Varsayılan değer
    this.yukseklik = 0.0, // Varsayılan değer
    this.genislik = 0.0, // Varsayılan değer
    this.miktar = 0, // Varsayılan değer
    this.desenYonu = "Yön Yok", // Varsayılan değer
    this.renk = "Renk Yok", // Varsayılan değer
  });

  // Firestore'dan veri çekerken kullanılan `fromMap` metodu
  factory IlanModel.fromMap(Map<String, dynamic> map, String id) {
    return IlanModel(
      id: id,
      baslik: map['baslik'] ?? "",
      aciklama: map['aciklama'] ?? "",
      kategori: map['kategori'] ?? "",
      il: map['il'] ?? "",
      ilce: map['ilce'] ?? "",
      mahalle: map['mahalle'] ?? "",
      olusturanKullaniciId: map['olusturanKullaniciId'] ?? "",
      olusturulmaTarihi: (map['olusturulmaTarihi'] as Timestamp?)?.toDate(),
      fiyat: map['fiyat']?.toDouble(),
      resimler:
          map['resimler'] != null ? List<String>.from(map['resimler']) : null,
      uretici: map['uretici'] ?? "",
      yukseklik: map['yukseklik']?.toDouble(),
      genislik: map['genislik']?.toDouble(),
      miktar: map['miktar']?.toInt(),
      desenYonu: map['desenYonu'] ?? "",
      renk: map['renk'] ?? "",
      en: map['en']?.toDouble(),
      
    );
  }

  // Firestore'a veri yazarken kullanılan `toMap` metodu
  Map<String, dynamic> toMap() {
    return {
      "en": en,
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
      'desenYonu': desenYonu,
      'renk': renk,
    };
  }
}
