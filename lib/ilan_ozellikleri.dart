import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projekaganebey/ilan_ozellikleri2.dart';
import 'package:toggle_switch/toggle_switch.dart';

class IlanOzellikleriPage extends StatefulWidget {
  final List<XFile?> images;

  IlanOzellikleriPage({required this.images});
  @override
  _IlanOzellikleriPageState createState() => _IlanOzellikleriPageState();
}

class _IlanOzellikleriPageState extends State<IlanOzellikleriPage> {
  String? selectedMaterial;
  String? selectedProducer;
  String? selectedColor;
  String? selectedDesenYonu;
  String selectedSize = 'Küçük';
  String selectedPattern = 'Desen Yok';
  int selectedQuantity = 1;

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

  final List<String> colorOptions = [
    'Doğal Ahşap',
    'Beyaz ve Açık',
    'Koyu Renkler',
    'Metalik ve Beton Efekti',
    'Canlı ve Renkli'
  ];

  final List<String> sizeOptions = ['Küçük', 'Orta', 'Büyük'];
  final List<String> patternOptions = ['Desen Yok', 'Desenli', 'Diğer Desen'];

  final List<String> materialOptions = ['PANEL', 'MDF LAM', 'SUNTA', "OSB"];
  bool isInputValid = true; // Track whether input values are valid

  void _validateInputs() {
    setState(() {
      // Check if all necessary inputs have been filled in to enable the button
      // Example: set isInputValid to true when all fields have values
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "İlan Özellikleri",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Yüklenen Fotoğraflar",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                SizedBox(
                  height: 80, // Fotoğrafların listeleneceği alanın yüksekliği
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.images.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image:
                                  FileImage(File(widget.images[index]!.path)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 13),
            _buildMaterialSelectionField(),
            SizedBox(height: 8), _buildProducerSelectionField(),
            SizedBox(height: 8),

            _buildDesenSelectionField(),
            SizedBox(height: 8), _buildColorSelectionField(),

            SizedBox(height: 12),
            Text(
              'Değerleri girdikten sonra ürün fiyatınız belirlenecektir',
              style: TextStyle(fontSize: 10, color: Colors.orange),
            ),
            SizedBox(height: 12),
            // Diğer bileşenler
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Birim Adet Fiyatı:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                SizedBox(
                  width: 100, // Set to your desired width
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: TextStyle(
                          fontSize: 17), // Larger font for the hint text
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 8), // Adjusted padding to center text
                    ),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center, // Center-align the input text
                    style: TextStyle(
                        fontSize: 12), // Larger font for input text as well
                    onChanged: (value) {
                      _validateInputs(); // Validate inputs on each change
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Devam et Button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isInputValid ? Colors.orange : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                onPressed: isInputValid
                    ? () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ProductPage(images: widget.images)));
                      }
                    // Action when button is active

                    : null, // Disable button when isInputValid is false
                child: Text(
                  'Devam et',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* Widget _buildMaterialSelectionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Malzeme',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 4),
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Malzeme',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: materialOptions.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(materialOptions[index]),
                          onTap: () {
                            setState(() {
                              selectedMaterial = materialOptions[index];
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Vazgeç'),
                    ),
                    SizedBox(height: 10),
                  ],
                );
              },
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedMaterial ?? 'Seçim yapınız',
                  style: TextStyle(fontSize: 12),
                ),
                Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }*/

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required ValueChanged<String?> onChanged,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item, style: TextStyle(fontSize: 12)),
            );
          }).toList(),
          hint: Text('Seçim yapınız', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildNumberInputField({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        SizedBox(height: 4),
        TextFormField(
          initialValue: value,
          keyboardType: TextInputType.number,
          onChanged: onChanged,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildMaterialSelectionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Malzeme',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 4),
        GestureDetector(
          onTap: _malzemeSec, // Malzeme seçim modalini açar
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedMaterial ?? 'Seçim yapınız',
                  style: TextStyle(fontSize: 12),
                ),
                Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProducerSelectionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Üretici',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 4),
        GestureDetector(
          onTap: _ureticiSec, // Üretici seçim modalini açar
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedProducer ?? 'Seçim yapınız',
                  style: TextStyle(fontSize: 12),
                ),
                Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelectionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Renk',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 4),
        GestureDetector(
          onTap: _renkSec, // Renk seçim modalini açar
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedColor ?? 'Seçim yapınız',
                  style: TextStyle(fontSize: 12),
                ),
                Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesenSelectionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Boyut, Miktar, Desen',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 4),
        GestureDetector(
          onTap: _boyutMiktarDesenSec, // Renk seçim modalini açar
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedColor ?? 'Seçim yapınız',
                  style: TextStyle(fontSize: 12),
                ),
                Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _malzemeSec() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height:
              MediaQuery.of(context).size.height * 0.5, // Yarı ekran yüksekliği
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Malzeme',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                // Kaydırılabilir liste
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: materialOptions.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      dense: true, // Öğeler arasındaki boşluğu azaltmak için
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      title: Text(
                        materialOptions[index],
                        style: TextStyle(fontSize: 14),
                      ),
                      onTap: () {
                        setState(() {
                          selectedMaterial = materialOptions[index];
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Vazgeç'),
                ),
              ),
              SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _boyutMiktarDesenSec() {
    bool isDesenSelected = false; // Desen seçimi için kontrol
    String selectedDesenYonu = 'yatay'; // ToggleSwitch'in varsayılan değeri

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Boyut, Miktar, Desen',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Boyut Alanı
                  Text('Boyut', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    'Ürün boyutlarını giriniz',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Yükseklik',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                          ),
                          keyboardType: TextInputType.number,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Genişlik',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                          ),
                          keyboardType: TextInputType.number,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // Miktar Alanı
                  Text('Miktar', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    'Ürün miktarını girin',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Miktar',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    ),
                    keyboardType: TextInputType.number,
                    style: TextStyle(fontSize: 14),
                  ),

                  SizedBox(height: 16),

                  // Desen Seçimi
                  Row(
                    children: [
                      Text('Desen Olacak Mı?',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Checkbox(
                        value: isDesenSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            isDesenSelected = value ?? false;
                          });
                        },
                      ),
                    ],
                  ),

                  // Desen Yönü ToggleSwitch
                  Text('Desen Yönü',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  ToggleSwitch(
                    initialLabelIndex: selectedDesenYonu == 'yatay' ? 0 : 1,
                    totalSwitches: 2,
                    labels: ['Yatay', 'Dikey'],
                    activeFgColor: Colors.orange,
                    inactiveBgColor: Colors.grey.shade300,
                    activeBgColor: [Color(0xFFF8F8F8)],
                    onToggle: isDesenSelected
                        ? (index) {
                            setState(() {
                              selectedDesenYonu =
                                  index == 0 ? 'yatay' : 'dikey';
                            });
                          }
                        : null, // Desen seçili değilse null atayarak devre dışı bırak
                  ),

                  SizedBox(height: 24),

                  // Vazgeç Butonu
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Vazgeç',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _ureticiSec() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height:
              MediaQuery.of(context).size.height * 0.5, // Yarı ekran yüksekliği
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Üretici',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                // Kaydırılabilir liste
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: manufacturers.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      dense: true, // Öğeler arasındaki boşluğu azaltmak için
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      title: Text(
                        manufacturers[index],
                        style: TextStyle(fontSize: 14),
                      ),
                      onTap: () {
                        setState(() {
                          selectedProducer = manufacturers[index];
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Vazgeç'),
              ),
              SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _renkSec() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height:
              MediaQuery.of(context).size.height * 0.5, // Yarı ekran yüksekliği
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Renk',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                // Kaydırılabilir liste
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: colorOptions.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      dense: true, // Öğeler arasındaki boşluğu azaltmak için
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      title: Text(
                        colorOptions[index],
                        style: TextStyle(fontSize: 14),
                      ),
                      onTap: () {
                        setState(() {
                          selectedColor = colorOptions[index];
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Vazgeç'),
              ),
              SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
