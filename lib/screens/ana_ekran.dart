import 'package:flutter/material.dart';
import 'package:Depot/screens/filtreleme_screen.dart';
import 'package:Depot/models/ilan_model.dart';
import 'package:Depot/services/firestore_services.dart';
import 'package:Depot/widgets/ilan_card.dart';
import 'package:Depot/widgets/kampanyalar_banner.dart';
import 'package:Depot/screens/notifications_page.dart';

class AdsMDFLamPage extends StatefulWidget {
  final List<Map<String, dynamic>>? filteredAds;
  final String? id;
  final String? category;
  final String? producer;
  final bool filtre;
  final bool hepsimi;
  AdsMDFLamPage({
    this.filteredAds,
    this.id,
    this.category,
    this.producer,
    this.filtre = false,
    this.hepsimi = false,
  });

  @override
  _AdsMDFLamPageState createState() => _AdsMDFLamPageState();
}

class _AdsMDFLamPageState extends State<AdsMDFLamPage> {
  final FirestoreService _firestoreService = FirestoreService();
  String _selectedSort = 'newest'; // Varsayılan sıralama
  int _ilanSayisi = 6; // Başlangıçta gösterilecek ilan sayısı

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsPage()),
              );
            },
            icon: Icon(Icons.notifications, color: Colors.blue),
          ),
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
          const KampanyalarBanner(),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                PopupMenuButton<String>(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 1,
                  child: Row(
                    children: [
                      Icon(Icons.sort, color: Colors.blueAccent),
                      Text("Sırala",
                          style: TextStyle(color: Colors.blueAccent)),
                    ],
                  ),
                  onSelected: (String value) {
                    setState(() {
                      _selectedSort = value;
                    });
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'newest',
                      child: Row(
                        children: [
                          Icon(Icons.arrow_upward,
                              color: Colors.grey, size: 20),
                          SizedBox(width: 8),
                          Text('En Yeniler', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'oldest',
                      child: Row(
                        children: [
                          Icon(Icons.arrow_downward,
                              color: Colors.grey, size: 20),
                          SizedBox(width: 8),
                          Text('En Eskiler', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'price_asc',
                      child: Row(
                        children: [
                          Icon(Icons.trending_up, color: Colors.grey, size: 20),
                          SizedBox(width: 8),
                          Text('Fiyat (Düşükten Yükseğe)',
                              style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'price_desc',
                      child: Row(
                        children: [
                          Icon(Icons.trending_down,
                              color: Colors.grey, size: 20),
                          SizedBox(width: 8),
                          Text('Fiyat (Yüksekten Düşüğe)',
                              style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FilterPage()),
                    );
                  },
                  child: Row(
                    children: [
                      Icon(Icons.filter_list, color: Colors.blueAccent),
                      SizedBox(width: 4),
                      Text("Filtrele",
                          style: TextStyle(color: Colors.blueAccent)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: widget.filtre == false && widget.filteredAds == null
                ? FutureBuilder<List<IlanModel>>(
                    future: _firestoreService.fetchAllIlanlar(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Hata: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('Henüz ilan bulunmuyor.'));
                      }

                      final ilanlar = _sortIlanlar(snapshot.data!);
                      final gosterilecekIlanlar =
                          ilanlar.take(_ilanSayisi).toList();
                      final hepsiGosterildi = _ilanSayisi >= ilanlar.length;

                      return Column(
                        children: [
                          Expanded(
                            child: GridView.builder(
                              padding: EdgeInsets.all(8.0),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 8.0,
                                crossAxisSpacing: 8.0,
                                childAspectRatio: 1,
                              ),
                              itemCount: gosterilecekIlanlar.length +
                                  (hepsiGosterildi ? 0 : 1),
                              itemBuilder: (context, index) {
                                if (index < gosterilecekIlanlar.length) {
                                  final ilan = gosterilecekIlanlar[index];
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
                                } else {
                                  return Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            alignment: Alignment.center,
                                            child: OutlinedButton(
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor:
                                                    Colors.blueAccent,
                                                side: BorderSide(
                                                    color: Colors.blueAccent),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 12,
                                                    horizontal: 20),
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _ilanSayisi += 6;
                                                });
                                              },
                                              child: Text("Daha Fazla Göster"),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  )
                : widget.filteredAds == null &&
                        (widget.category?.isNotEmpty ?? false)
                    ? FutureBuilder<List<IlanModel>>(
                        future:
                            _firestoreService.fetchIlanlarByCategoryAndProducer(
                                widget.category,
                                widget.producer,
                                widget.hepsimi),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Hata: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Center(
                                child: Text('Henüz ilan bulunmuyor.'));
                          }

                          final ilanlar = _sortIlanlar(snapshot.data!);
                          final gosterilecekIlanlar =
                              ilanlar.take(_ilanSayisi).toList();
                          final hepsiGosterildi = _ilanSayisi >= ilanlar.length;

                          return Column(
                            children: [
                              Expanded(
                                child: GridView.builder(
                                  padding: EdgeInsets.all(8.0),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 8.0,
                                    crossAxisSpacing: 8.0,
                                    childAspectRatio: 1,
                                  ),
                                  itemCount: gosterilecekIlanlar.length +
                                      (hepsiGosterildi ? 0 : 1),
                                  itemBuilder: (context, index) {
                                    if (index < gosterilecekIlanlar.length) {
                                      final ilan = gosterilecekIlanlar[index];
                                      debugPrint('Ilan: ${ilan.resimler![0]}');
                                      return buildIlanCard(
                                        userId: widget.id,
                                        baslik: ilan.baslik,
                                        fiyat: ilan.fiyat,
                                        resimUrl:
                                            ilan.resimler?.isNotEmpty == true
                                                ? ilan.resimler![0]
                                                : null,
                                        ilanID: ilan.id!,
                                        kendiIlanim: false,
                                        context: context,
                                      );
                                    } else {
                                      return Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                alignment: Alignment.center,
                                                child: OutlinedButton(
                                                  style:
                                                      OutlinedButton.styleFrom(
                                                    foregroundColor:
                                                        Colors.blueAccent,
                                                    side: BorderSide(
                                                        color:
                                                            Colors.blueAccent),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 12,
                                                            horizontal: 20),
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      _ilanSayisi += 6;
                                                    });
                                                  },
                                                  child:
                                                      Text("Daha Fazla Göster"),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      )
                    : widget.filteredAds != null
                        ? GridView.builder(
                            padding: const EdgeInsets.all(8.0),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount:
                                  2, // Kaç sütun olacağını belirleyin
                              mainAxisSpacing: 8.0,
                              crossAxisSpacing: 8.0,
                              childAspectRatio: 1,
                            ),
                            itemCount: widget.filteredAds?.length ?? 0,
                            itemBuilder: (context, index) {
                              final ilan = widget.filteredAds![index];
                              debugPrint('Ilan: ${ilan}');

                              return buildIlanCard(
                                userId: widget.id,
                                baslik: ilan['baslik'] ?? 'Başlık Yok',
                                fiyat: (ilan['fiyat'] != null)
                                    ? ilan['fiyat'].toDouble()
                                    : 0.0,
                                resimUrl: (ilan['resimler'] != null &&
                                        ilan['resimler'].isNotEmpty)
                                    ? ilan['resimler'][0]
                                    : null,
                                ilanID: ilan['id'] ?? "",
                                context: context,
                              );
                            })
                        : Center(child: Text('Henüz ilan bulunmuyor.')),
          ),
        ],
      ),
    );
  }
}
