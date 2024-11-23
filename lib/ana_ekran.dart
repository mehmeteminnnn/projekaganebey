import 'package:flutter/material.dart';
import 'package:projekaganebey/filtre.dart';
import 'package:projekaganebey/models/ilan.dart';
import 'package:projekaganebey/services/firestore_services.dart';

class AdsMDFLamPage extends StatefulWidget {
  @override
  _AdsMDFLamPageState createState() => _AdsMDFLamPageState();

  final List<Map<String, dynamic>>? filteredAds;

  AdsMDFLamPage({this.filteredAds});
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
                      MaterialPageRoute(builder: (context) => FilterPage()),
                    );
                  },
                  child: Icon(Icons.filter_list, color: Colors.blueAccent),
                ),
              ],
            ),
          ),
          Expanded(
            child: widget.filteredAds != null && widget.filteredAds!.isNotEmpty
                ? GridView.builder(
                    padding: EdgeInsets.all(8.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8.0,
                      crossAxisSpacing: 8.0,
                      childAspectRatio: 1,
                    ),
                    itemCount: widget.filteredAds!.length,
                    itemBuilder: (context, index) {
                      final ilan = widget.filteredAds![index];
                      return _buildIlanCard(
                        baslik: ilan['baslik'],
                        fiyat: (ilan['fiyat'] != null
                            ? ilan['fiyat'].toDouble()
                            : 0),
                        resimUrl: ilan['resimler']?.isNotEmpty == true
                            ? ilan['resimler'][0]
                            : null,
                      );
                    },
                  )
                : widget.filteredAds != null && widget.filteredAds!.isEmpty
                    ? Center(
                        child: Text('Aradığınız ilan bulunamadı.'),
                      )
                    : FutureBuilder<List<IlanModel>>(
                        future: _firestoreService
                            .fetchIlanlarByCategory(selectedChip),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text('Hata: ${snapshot.error}'),
                            );
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Center(
                              child: Text('Henüz ilan bulunmuyor.'),
                            );
                          }

                          final ilanlar = snapshot.data!;
                          return GridView.builder(
                            padding: EdgeInsets.all(8.0),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 8.0,
                              crossAxisSpacing: 8.0,
                              childAspectRatio: 1,
                            ),
                            itemCount: ilanlar.length,
                            itemBuilder: (context, index) {
                              final ilan = ilanlar[index];
                              return _buildIlanCard(
                                baslik: ilan.baslik,
                                fiyat: ilan.fiyat,
                                resimUrl: ilan.resimler?.isNotEmpty == true
                                    ? ilan.resimler![0]
                                    : null,
                              );
                            },
                          );
                        },
                      ),
          )
        ],
      ),
    );
  }

  Widget _buildIlanCard({
    String? baslik,
    double? fiyat,
    String? resimUrl,
  }) {
    return Card(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Image.network(
              resimUrl ??
                  'https://ideacdn.net/idea/ar/16/myassets/products/353/pr_01_353.jpg?revision=1697143329',
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
                  baslik ?? 'Ürün Adı',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Fiyat: ${fiyat ?? 'Bilinmiyor'} TL',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
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
