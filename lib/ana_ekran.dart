import 'package:flutter/material.dart';
import 'package:projekaganebey/filtre_kapali.dart';
import 'package:projekaganebey/models/ilan.dart';
import 'package:projekaganebey/services/firestore_services.dart';

class AdsMDFLamPage extends StatefulWidget {
  @override
  _AdsMDFLamPageState createState() => _AdsMDFLamPageState();
}

class _AdsMDFLamPageState extends State<AdsMDFLamPage> {
  final FirestoreService _firestoreService = FirestoreService();
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
                    // Filtre sayfasına yönlendirme
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
            child: FutureBuilder<List<IlanModel>>(
              future: _firestoreService.fetchIlanlar(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Hata: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Henüz ilan bulunmuyor.'));
                }

                final ilanlar = snapshot.data!;

                return GridView.builder(
                  padding: EdgeInsets.all(8.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                    childAspectRatio: 1,
                  ),
                  itemCount: ilanlar.length,
                  itemBuilder: (context, index) {
                    final ilan = ilanlar[index];
                    return Card(
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Image.network(
                              ilan.resimler?.isNotEmpty == true
                                  ? ilan.resimler![0]
                                  : 'https://ideacdn.net/idea/ar/16/myassets/products/353/pr_01_353.jpg?revision=1697143329',
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ilan.baslik ?? 'Ürün Adı',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Fiyat: ${ilan.fiyat} TL',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
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
      selectedColor: Colors.blue,
      backgroundColor: Colors.white,
      side: BorderSide.none,
      onSelected: (isSelected) {
        setState(() {
          selectedChip = isSelected ? label : null;
        });
      },
    );
  }
}
