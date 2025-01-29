import 'package:flutter/material.dart';
import 'package:projekaganebey/screens/filtreleme_screen.dart';
import 'package:projekaganebey/models/ilan_model.dart';
import 'package:projekaganebey/services/firestore_services.dart';
import 'package:projekaganebey/widgets/ilan_card.dart';
import 'package:projekaganebey/widgets/kampanyalar_banner.dart';
import 'package:projekaganebey/screens/notifications_page.dart';

class AdsMDFLamPage extends StatefulWidget {
  @override
  _AdsMDFLamPageState createState() => _AdsMDFLamPageState();

  final List<Map<String, dynamic>>? filteredAds;
  final String? id;
  final String? category;
  final String? producer;
  final bool filtre;

  AdsMDFLamPage(
      {this.filteredAds,
      this.id,
      this.category,
      this.producer,
      this.filtre = false});
}

class _AdsMDFLamPageState extends State<AdsMDFLamPage> {
  final FirestoreService _firestoreService = FirestoreService();
  String searchQuery = ''; // Arama metni
  final int notificationCount = 5; // Bildirim sayısı
  String _selectedSort = 'newest'; // Varsayılan sıralama seçeneği

  // Sıralama fonksiyonu
  List<IlanModel> _sortIlanlar(List<IlanModel> ilanlar) {
    if (_selectedSort == 'newest') {
      ilanlar.sort((a, b) => (b.olusturulmaTarihi ?? DateTime(0))
          .compareTo(a.olusturulmaTarihi ?? DateTime(0)));
    } else if (_selectedSort == 'oldest') {
      ilanlar.sort((a, b) => (a.olusturulmaTarihi ?? DateTime(0))
          .compareTo(b.olusturulmaTarihi ?? DateTime(0)));
    } else if (_selectedSort == 'price_asc') {
      ilanlar.sort((a, b) => (a.fiyat ?? 0).compareTo(b.fiyat ?? 0));
    } else if (_selectedSort == 'price_desc') {
      ilanlar.sort((a, b) => (b.fiyat ?? 0).compareTo(a.fiyat ?? 0));
    }
    return ilanlar;
  }

  /* // Firestore'dan ilanları arama
  Future<void> _searchAds(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchQuery = '';
        filteredIlanlar = null;
      });
      return;
    }

    final results = await _firestoreService.searchIlanlarByTitle(query);
    setState(() {
      searchQuery = query;
      filteredIlanlar = results;
    });
  }
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NotificationsPage()));
              },
              icon: Icon(
                Icons.notifications,
                color: Colors.blue,
              ))
        ],
        backgroundColor: Colors.white,
        title: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Kelime veya ilan no ile ara',
              border: InputBorder.none,
              icon: Icon(Icons.search, color: Colors.grey),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const KampanyalarBanner(), // Kampanyalar Widget'ı
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Sıralama Kısmı
                PopupMenuButton<String>(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 1,
                  child: Row(
                    children: [
                      Icon(Icons.sort, color: Colors.blueAccent),
                      Text(
                        "Sırala",
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ],
                  ),
                  onSelected: (String value) {
                    setState(() {
                      _selectedSort = value;
                    });
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'newest',
                      child: Row(
                        children: [
                          Icon(Icons.arrow_upward, color: Colors.grey, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'En Yeniler',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'oldest',
                      child: Row(
                        children: [
                          Icon(Icons.arrow_downward, color: Colors.grey, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'En Eskiler',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'price_asc',
                      child: Row(
                        children: [
                          Icon(Icons.trending_up, color: Colors.grey, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Fiyat (Düşükten Yükseğe)',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'price_desc',
                      child: Row(
                        children: [
                          Icon(Icons.trending_down, color: Colors.grey, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Fiyat (Yüksekten Düşüğe)',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Filtreleme Kısmı
                TextButton(
                  onPressed: () {
                    // Filtre sayfasına yönlendirme
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FilterPage()),
                    );
                  },
                  child: Row(
                    children: [
                      Icon(Icons.filter_list, color: Colors.blueAccent),
                      SizedBox(width: 4), // İkon ile yazı arasına boşluk ekler
                      Text(
                        "Filtrele",
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
              child: widget.filtre == false
                  // Filtre false ise, tüm ilanları göster
                  ? FutureBuilder<List<IlanModel>>(
                      future: _firestoreService.fetchAllIlanlar(),
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

                        final ilanlar = _sortIlanlar(snapshot.data!);
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
                            return buildIlanCard(
                              userId: widget.id,
                              baslik: ilan.baslik,
                              fiyat: ilan.fiyat,
                              resimUrl: ilan.resimler?.isNotEmpty == true
                                  ? ilan.resimler![0]
                                  : null,
                              ilanID: ilan.id!,
                              kendiIlanim: false,
                              context: context,
                              category: ilan.kategori,
                            );
                          },
                        );
                      },
                    )
                  : widget.filteredAds == null &&
                          (widget.category?.isNotEmpty ?? false)
                      // Filtre true ise, kategori ve üreticiye göre ilanları göster
                      ? FutureBuilder<List<IlanModel>>(
                          future: _firestoreService
                              .fetchIlanlarByCategoryAndProducer(
                                  widget.category, widget.producer),
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

                            final ilanlar = _sortIlanlar(snapshot.data!);
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
                                return buildIlanCard(
                                  userId: widget.id,
                                  baslik: ilan.baslik,
                                  fiyat: ilan.fiyat,
                                  resimUrl: ilan.resimler?.isNotEmpty == true
                                      ? ilan.resimler![0]
                                      : null,
                                  ilanID: ilan.id!,
                                  kendiIlanim: false,
                                  context: context,
                                );
                              },
                            );
                          },
                        )
                      : Center(
                          child: Text('Aradığınız ilan bulunamadı.'),
                        )),
        ],
      ),
    );
  }

  /* Widget _buildFilterChip(String label) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontWeight: selectedChip == label ? FontWeight.bold : FontWeight.normal,
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
  } */
}
