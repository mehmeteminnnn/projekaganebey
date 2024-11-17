import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projekaganebey/constants/constants.dart';
import 'package:projekaganebey/ilan_ozellikleri2.dart';
import 'package:projekaganebey/models/ilan.dart';
import 'package:toggle_switch/toggle_switch.dart';

class IlanOzellikleriPage extends StatefulWidget {
  final List<XFile?> images;
  final IlanModel ilan;

  IlanOzellikleriPage({required this.images, required this.ilan});

  @override
  _IlanOzellikleriPageState createState() => _IlanOzellikleriPageState();
}

class _IlanOzellikleriPageState extends State<IlanOzellikleriPage> {
  String? selectedMaterial;
  String? selectedProducer;
  String? selectedColor;
  String? selectedDesenYonu;
  final TextEditingController _FiyatController = TextEditingController();

  String boyutYukseklik = "?";
  String boyutGenislik = "?";
  String miktar = "?";
  bool isInputValid = false;

  // Lists of options
  final List<String> manufacturers = AppConstants.manufacturers;
  final List<String> colorOptions = AppConstants.colorOptions;
  final List<String> materialOptions = AppConstants.materialOptions;
  //final List<String> sizeOptions = AppConstants.sizeOptions;

  void _validateInputs() {
    setState(() {
      // Tüm alanlar için geçerlilik kontrolü
      isInputValid = selectedMaterial != null &&
          selectedProducer != null &&
          selectedColor != null &&
          boyutYukseklik.isNotEmpty &&
          boyutGenislik.isNotEmpty &&
          miktar.isNotEmpty;
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
            // Photo section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Yüklenen Fotoğraflar",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                SizedBox(
                  height: 80,
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

            // Material selection
            _buildSelectionField(
              label: "Malzeme",
              selectedValue: selectedMaterial,
              onChanged: (value) {
                setState(() {
                  selectedMaterial = value;
                });
                _validateInputs();
              },
              items: materialOptions,
              isMaterial: true,
            ),
            SizedBox(height: 8),

            // Producer selection
            _buildSelectionField(
              label: "Üretici",
              selectedValue: selectedProducer,
              onChanged: (value) {
                setState(() {
                  selectedProducer = value;
                });
                _validateInputs();
              },
              items: manufacturers,
              isProducer: true,
            ),
            SizedBox(height: 8),

            // Desen selection
            _buildDesenSelectionField(),
            SizedBox(height: 8),

            // Color selection
            _buildSelectionField(
              label: "Renk",
              selectedValue: selectedColor,
              onChanged: (value) {
                setState(() {
                  selectedColor = value;
                });
                _validateInputs();
              },
              items: colorOptions,
              isColor: true,
            ),
            SizedBox(height: 12),

            // Price information
            Text(
              'Değerleri girdikten sonra ürün fiyatınız belirlenecektir',
              style: TextStyle(fontSize: 10, color: Colors.orange),
            ),
            SizedBox(height: 12),

            // Price input field
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Birim Adet Fiyatı:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _FiyatController,
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: TextStyle(fontSize: 17),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    ),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                    onChanged: (value) {
                      _validateInputs();
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Continue button
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
                        widget.ilan.yukseklik = double.tryParse(boyutYukseklik);
                        widget.ilan.genislik = double.tryParse(boyutGenislik);
                        widget.ilan.miktar = int.tryParse(miktar);
                        widget.ilan.kategori = selectedMaterial;
                        widget.ilan.uretici = selectedProducer;
                        widget.ilan.renk = selectedColor;
                        widget.ilan.desenYonu = selectedDesenYonu;
                        widget.ilan.fiyat =
                            double.tryParse(_FiyatController.text);
                        widget.ilan.olusturulmaTarihi = DateTime.now();

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProductPage(
                                    images: widget.images, ilan: widget.ilan)));
                      }
                    : null,
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

  Widget _buildSelectionField({
    required String label,
    required String? selectedValue,
    required ValueChanged<String?> onChanged,
    required List<String> items,
    String hint = 'Seçim yapınız',
    bool isMaterial = false,
    bool isProducer = false,
    bool isColor = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        SizedBox(height: 4),
        GestureDetector(
          onTap: () => isMaterial
              ? _malzemeSec()
              : isProducer
                  ? _ureticiSec()
                  : isColor
                      ? _renkSec()
                      : null,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(selectedValue ?? hint, style: TextStyle(fontSize: 12)),
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
                  child: Text('Vazgeç', style: TextStyle(color: Colors.red)),
                ),
              ),
              SizedBox(height: 8),
            ],
          ),
        );
      },
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
                  // Eğer boyutGenislik, boyutYukseklik ve miktar null değilse, bunları yazdır
                  //boyutGenislik != null && boyutYukseklik != null && miktar != null
                  "[$boyutGenislik][$boyutYukseklik]*$miktar",
                  // : selectedColor ?? 'Seçim yapınız', // Eğer herhangi biri null ise sadece selectedColor yazdır
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
                          onChanged: (value) {
                            boyutYukseklik = value; // Değeri kaydet
                          },
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
                          onChanged: (value) {
                            boyutGenislik = value; // Değeri kaydet
                          },
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
                    onChanged: (value) {
                      miktar = value; // Değeri kaydet
                    },
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
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child:
                          Text('Vazgeç', style: TextStyle(color: Colors.red)),
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
              SizedBox(height: 6),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Vazgeç', style: TextStyle(color: Colors.red)),
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
                child: Text('Vazgeç', style: TextStyle(color: Colors.red)),
              ),
              SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
