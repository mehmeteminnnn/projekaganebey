import 'package:flutter/material.dart';

class AdreslerimPage extends StatefulWidget {
  @override
  _AdreslerimPageState createState() => _AdreslerimPageState();
}

class _AdreslerimPageState extends State<AdreslerimPage> {
  // Örnek adres listesi
  List<Map<String, String>> adresler = [
    {
      "baslik": "Ev Adresi",
      "adres": "123 Sokak, Mahalle, İlçe, Şehir",
    },
    {
      "baslik": "İş Adresi",
      "adres": "456 Cadde, İş Merkezi, Şehir",
    },
  ];

  // Yeni adres ekleme fonksiyonu
  void _yeniAdresEkle() {
    _adresFormuAc();
  }

  // Adres düzenleme fonksiyonu
  void _duzenleAdres(int index) {
    _adresFormuAc(index: index);
  }

  // Adres formu açma (Ekleme ve Düzenleme)
  void _adresFormuAc({int? index}) {
    String baslik = index != null ? adresler[index]['baslik']! : "";
    String adres = index != null ? adresler[index]['adres']! : "";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(index != null ? "Adresi Düzenle" : "Yeni Adres Ekle"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(text: baslik),
                decoration: const InputDecoration(labelText: "Adres Başlığı"),
                onChanged: (value) {
                  baslik = value;
                },
              ),
              TextField(
                controller: TextEditingController(text: adres),
                decoration: const InputDecoration(labelText: "Adres"),
                maxLines: 2,
                onChanged: (value) {
                  adres = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("İptal"),
            ),
            ElevatedButton(
              onPressed: () {
                if (baslik.isNotEmpty && adres.isNotEmpty) {
                  setState(() {
                    if (index != null) {
                      // Düzenleme
                      adresler[index] = {"baslik": baslik, "adres": adres};
                    } else {
                      // Yeni adres ekleme
                      adresler.add({"baslik": baslik, "adres": adres});
                    }
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text(index != null ? "Kaydet" : "Ekle"),
            ),
          ],
        );
      },
    );
  }

  // Adres silme işlemi
  void _silAdres(int index) {
    setState(() {
      adresler.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Adreslerim",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: adresler.isEmpty
                  ? const Center(
                      child: Text(
                        "Henüz adres eklemediniz.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: adresler.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading:
                                const Icon(Icons.location_on, color: Colors.blue),
                            title: Text(
                              adresler[index]['baslik']!,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(adresler[index]['adres']!),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.orange),
                                  onPressed: () => _duzenleAdres(index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _silAdres(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            ElevatedButton.icon(
              onPressed: _yeniAdresEkle,
              icon: const Icon(
                Icons.add,
                color: Colors.blue,
              ),
              label: const Text(
                "Yeni Adres Ekle",
                style: TextStyle(color: Colors.blue),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
