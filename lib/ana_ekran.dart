import 'package:flutter/material.dart';
import 'package:projekaganebey/filtre_kapali.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AdsMDFLamPage(),
    );
  }
}

class AdsMDFLamPage extends StatefulWidget {
  @override
  _AdsMDFLamPageState createState() => _AdsMDFLamPageState();
}

class _AdsMDFLamPageState extends State<AdsMDFLamPage> {
  String? selectedChip;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Kelime veya ilan No. ile ara',
              border: InputBorder.none,
              icon: Icon(Icons.search, color: Colors.grey),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFilterChip('MDF LAM'),
                _buildFilterChip('PANEL'),
                _buildFilterChip('SUNTA'),
                _buildFilterChip('OSB'),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FilterClosedPage()),
                    );
                  },
                  child: Icon(Icons.filter_list, color: Colors.blueAccent),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                childAspectRatio: 1,
              ),
              itemCount: 8, // Örnek veri sayısı
              itemBuilder: (context, index) {
                return Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Image.network(
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQawqtJhPwEwraVo1blPjWFfYOccejfriHRKw&s', // Örnek resim URL'si
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Ürün Adı',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text('Fiyat: 1.345 TL',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontWeight:
              selectedChip == label ? FontWeight.bold : FontWeight.normal,
          color: selectedChip == label ? Colors.black : Colors.grey,
        ),
      ),
      selected: selectedChip == label,
      selectedColor: Colors.blue, // Background color when selected
      backgroundColor: Colors.transparent, // Always transparent background
      onSelected: (isSelected) {
        setState(() {
          selectedChip = isSelected ? label : null;
        });
      },
      side: BorderSide.none, // Remove border for all chips
    );
  }
}
