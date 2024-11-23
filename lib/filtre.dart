import 'package:flutter/material.dart';
import 'package:projekaganebey/ana_ekran.dart';
import 'package:projekaganebey/constants/constants.dart';
import 'package:projekaganebey/services/firestore_services.dart';

class FilterPage extends StatefulWidget {
  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  var selectedIl;
  var selectedIlce;
  final List<String> manufacturers = AppConstants.manufacturers;
  final List<String> colorOptions = AppConstants.colorOptions;
  final List<String> materialOptions = AppConstants.materialOptions;
  TextEditingController minpriceController = TextEditingController();
  TextEditingController maxpriceController = TextEditingController();

  List<bool> manufacturerSelections = List.generate(14, (_) => false);
  String? selectedDesenYonu;
  RangeValues fiyatRange = RangeValues(0, 10000); // Price range
  String? selectedColor;
  void updatePriceRange() {
    double? minPrice = double.tryParse(minpriceController.text);
    double? maxPrice = double.tryParse(maxpriceController.text);

    // Değerlerin geçerli olup olmadığını kontrol et
    if (minPrice != null && maxPrice != null) {
      setState(() {
        // Min ve max fiyatları priceRange'e ata
        fiyatRange = RangeValues(minPrice, maxPrice);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text("Filtreler",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            )),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ExpansionTile(
            title: Text(
              'Üreticiler',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black.withOpacity(0.8),
              ),
            ),
            children: List.generate(manufacturers.length, (index) {
              return CheckboxListTile(
                title: Text(
                  manufacturers[index],
                  style: TextStyle(
                    color: Color(0xFF404040),
                    fontSize: 16,
                    fontFamily: 'Satoshi',
                    fontWeight: FontWeight.w500,
                    height: 0,
                  ),
                ),
                value: manufacturerSelections[index],
                onChanged: (bool? value) {
                  setState(() {
                    manufacturerSelections[index] = value ?? false;
                  });
                },
              );
            }),
          ),
          ExpansionTile(
            title: Text(
              'Boyut ve Desen',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black.withOpacity(0.8),
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Boyut seç',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),

                    // Height Row
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Yükseklik',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Flexible(
                              child: Column(
                                children: [
                                  TextField(
                                    decoration: InputDecoration(
                                      hintStyle: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                      hintText: 'min',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            8), // Küçük radius
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 6, // Daha dar boşluk
                                        horizontal: 6,
                                      ),
                                    ),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 14), // Daha küçük yazı boyutu
                                    keyboardType: TextInputType.number,
                                  ),
                                  SizedBox(height: 4),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4.0), // Daha dar aralık
                              child: Text('-',
                                  style: TextStyle(
                                      fontSize: 14)), // Daha küçük tire
                            ),
                            Flexible(
                              child: Column(
                                children: [
                                  TextField(
                                    decoration: InputDecoration(
                                      hintStyle: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                      hintText: 'max',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 6,
                                        horizontal: 6,
                                      ),
                                    ),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 14),
                                    keyboardType: TextInputType.number,
                                  ),
                                  SizedBox(height: 4),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Width Row
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Genişlik',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  TextField(
                                    decoration: InputDecoration(
                                      hintStyle: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                      hintText: 'min',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade400),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 8),
                                    ),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 16),
                                    keyboardType: TextInputType.number,
                                  ),
                                  SizedBox(height: 4),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text('-', style: TextStyle(fontSize: 18)),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  TextField(
                                    decoration: InputDecoration(
                                      hintStyle: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                      hintText: 'max',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade400),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 8),
                                    ),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 16),
                                    keyboardType: TextInputType.number,
                                  ),
                                  SizedBox(height: 4),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Pattern Direction
                    Text(
                      'Desen yönü',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        ChoiceChip(
                          label: Text('Yatay',
                              style: TextStyle(
                                  color: selectedDesenYonu == 'Yatay'
                                      ? Colors.orange
                                      : Colors.black)),
                          selected: selectedDesenYonu == 'Yatay',
                          selectedColor: Colors.orange.withOpacity(0.2),
                          onSelected: (selected) {
                            setState(() {
                              selectedDesenYonu = selected ? 'Yatay' : null;
                            });
                          },
                        ),
                        SizedBox(width: 8),
                        ChoiceChip(
                          label: Text('Dikey',
                              style: TextStyle(
                                  color: selectedDesenYonu == 'Dikey'
                                      ? Colors.orange
                                      : Colors.black)),
                          selected: selectedDesenYonu == 'Dikey',
                          selectedColor: Colors.orange.withOpacity(0.2),
                          onSelected: (selected) {
                            setState(() {
                              selectedDesenYonu = selected ? 'Dikey' : null;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text(
              'Fiyat',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black.withOpacity(0.8),
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fiyat Aralığı',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: minpriceController,
                            onChanged: (value) {
                              updatePriceRange(); // Fiyat değiştiğinde aralığı güncelle
                            },
                            decoration: InputDecoration(
                              hintStyle:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                              hintText: 'min',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 8),
                            ),
                            style: TextStyle(fontSize: 14),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: maxpriceController,
                            onChanged: (value) {
                              updatePriceRange(); // Fiyat değiştiğinde aralığı güncelle
                            },
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintStyle:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                              hintText: 'max',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 8),
                            ),
                            style: TextStyle(fontSize: 14),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text(
              'Renk',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black.withOpacity(0.8),
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  spacing: 8.0,
                  children: colorOptions.map((color) {
                    return ChoiceChip(
                      label: Text(color),
                      selected: selectedColor == color,
                      onSelected: (selected) {
                        setState(() {
                          selectedColor = selected ? color : null;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text(
              'Konum',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black.withOpacity(0.8),
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'İl Seç',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonFormField<String>(
                        hint: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('İl Seçin'),
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                        ),
                        items:
                            ['İstanbul', 'Ankara', 'İzmir', 'Bursa', 'Antalya']
                                .map((il) => DropdownMenuItem(
                                      value: il,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Text(il),
                                      ),
                                    ))
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedIl = value;
                          });
                        },
                        value: selectedIl,
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'İlçe Seç',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonFormField<String>(
                        hint: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('İlçe Seçin'),
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                        ),
                        items: [
                          'Kadıköy',
                          'Beşiktaş',
                          'Üsküdar',
                          'Çankaya',
                          'Keçiören'
                        ]
                            .map((ilce) => DropdownMenuItem(
                                  value: ilce,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Text(ilce),
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedIlce = value;
                          });
                        },
                        value: selectedIlce,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: 150,
              child: ElevatedButton(
                onPressed: applyFilters,
                child: Text('Filtrele', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void applyFilters() {
    // Burada filtreler Firestore'a gönderilir veya veriler filtrelenir.
    final filters = {
      'selectedIl': selectedIl,
      'selectedIlce': selectedIlce,
      'manufacturers': manufacturers
          .asMap()
          .entries
          .where((entry) => manufacturerSelections[entry.key])
          .map((entry) => entry.value)
          .toList(),
      'selectedDesenYonu': selectedDesenYonu,
      'fiyat': {
        'min': double.tryParse(minpriceController.text),
        'max': double.tryParse(maxpriceController.text)
      },
      'selectedColor': selectedColor,
    };
    print(filters); // Test için filtre değerlerini konsola yazdırıyoruz.

    // FirestoreService'de filtrelere uygun fonksiyon çağırma
    FirestoreService().getFilteredAds(filters).then((ads) {
      // AdsMdfLamPage sayfasını filtrelenmiş ilanlarla güncelleyin.
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdsMDFLamPage(
              filteredAds: ads,
            ),
          ));
    });
  }
}
