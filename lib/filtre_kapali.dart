import 'package:flutter/material.dart';

class FilterClosedPage extends StatefulWidget {
  @override
  _FilterClosedPageState createState() => _FilterClosedPageState();
}

class _FilterClosedPageState extends State<FilterClosedPage> {
  var selectedIl;
  var selectedIlce;
  final List<String> manufacturers = [
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
    'Seloit'
  ];

  List<bool> manufacturerSelections = List.generate(14, (_) => false);
  String? selectedDesenYonu;
  RangeValues priceRange = RangeValues(0, 10000); // Price range
  String? selectedColor;

  final List<String> colorOptions = [
    'Doğal Ahşap',
    'Beyaz ve Açık',
    'Koyu Renkler',
    'Metalik ve Beton Efekti',
    'Canlı ve Renkli'
  ];

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
            initiallyExpanded: true,
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
                            Expanded(
                              child: Column(
                                children: [
                                  TextField(
                                    decoration: InputDecoration(
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
                                  Text('min',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey)),
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
                                  Text('max',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey)),
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
                                  Text('min',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey)),
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
                                  Text('max',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey)),
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
            initiallyExpanded: true,
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
                            decoration: InputDecoration(
                              hintText: 'min',
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
                        SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
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
            initiallyExpanded: true,
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
          )
        ],
      ),
    );
  }
}
