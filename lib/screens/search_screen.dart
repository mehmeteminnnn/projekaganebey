import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Depot/screens/search_product_filter_screen.dart';
import 'package:Depot/models/ilan_model.dart';
import 'package:Depot/ilan_detay.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> getDocumentCount(String collectionName) async {
    try {
      final querySnapshot = await _firestore.collection(collectionName).get();
      return querySnapshot.docs.length;
    } catch (e) {
      print('Error fetching document count: $e');
      return 0;
    }
  }

  Future<List<IlanModel>> getRandomIlanlar(String collection, int limit) async {
    try {
      final querySnapshot = await _firestore.collection(collection).get();
      final docs = querySnapshot.docs..shuffle();
      final randomDocs = docs.take(limit).toList();

      return randomDocs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return IlanModel.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      print("Hata: $e");
      return [];
    }
  }
}

class SearchPage extends StatefulWidget {
  String? id;
  SearchPage({required this.id});
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final FirestoreService _firestoreService = FirestoreService();
  Map<String, int> _categoryCounts = {};
  List<IlanModel> _randomIlanlar = [];

  @override
  void initState() {
    super.initState();
    _fetchCategoryCounts();
    _fetchRandomIlanlar();
  }

  Future<void> _fetchCategoryCounts() async {
    final categories = ['mdf_lam', 'panel', 'sunta', 'osb'];
    final Map<String, int> counts = {};

    for (var category in categories) {
      final count = await _firestoreService.getDocumentCount(category);
      counts[category] = count;
    }

    setState(() {
      _categoryCounts = counts;
    });
  }

  Future<void> _fetchRandomIlanlar() async {
    final ilanlar = await _firestoreService.getRandomIlanlar('mdf_lam', 5);
    setState(() {
      _randomIlanlar = ilanlar;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Arama',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          /*Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
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
          ),*/
          Expanded(
            child: ListView(
              children: [
                // Kategoriler
                Column(
                  children: [
                    _buildCategoryItem('MDF Lam', 'mdf_lam', 'assets/mdf.webp'),
                    _buildCategoryItem('Panel', 'panel', 'assets/panel.webp'),
                    _buildCategoryItem('Sunta', 'sunta', 'assets/sunta.jpg'),
                    _buildCategoryItem('OSB', 'osb', 'assets/osb.jpg'),
                  ],
                ),
                Divider(),
                // İlgilenebileceğiniz İlanlar
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    'İlgilenebileceğiniz İlanlar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _randomIlanlar.length,
                  itemBuilder: (context, index) {
                    final ilan = _randomIlanlar[index];

                    return Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: _buildAdItem(ilan),
                        ),
                        if (index !=
                            _randomIlanlar.length -
                                1) // Son item değilse divider ekle
                          Divider(
                              height: 1,
                              thickness: 1,
                              indent: 16,
                              endIndent: 16),
                      ],
                    );
                  },
                ),

                Divider(),
                // Son Gezindiğiniz İlanlar
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
      String title, String collectionName, String assetImage) {
    final count = _categoryCounts[collectionName] ?? 0;

    return ListTile(
      leading: Image.asset(assetImage, width: 40, height: 40),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: Text('($count) >',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FilterProductPage(
                category: collectionName,
                title: title), // title = kategori ismi
          ),
        );
      },
    );
  }

  Widget _buildAdItem(IlanModel ilan) {
    return ListTile(
      leading: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8.0),
          image: ilan.resimler != null && ilan.resimler!.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(ilan.resimler!.first),
                  fit: BoxFit.cover,
                )
              : null,
        ),
      ),
      title: Text(
        ilan.baslik ?? 'Başlıksız İlan',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: Text(
        '${ilan.fiyat?.toString() ?? '0'} ₺',
        style: TextStyle(
          color: Colors.blueAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IlanDetayPage(
              id: widget.id,
              ilanId: ilan.id!,
              ilanbaslik: ilan.baslik,
              kendiIlanim: false,
              kategori: ilan.kategori,
            ),
          ),
        );
        // İlan detayına yönlendirme yapılabilir
      },
    );
  }
}
