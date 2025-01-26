import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projekaganebey/screens/search_product_filter_screen.dart';

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
}

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final FirestoreService _firestoreService = FirestoreService();
  Map<String, int> _categoryCounts = {};

  @override
  void initState() {
    super.initState();
    _fetchCategoryCounts();
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
          Container(
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
          ),
          Expanded(
            child: ListView(
              children: [
                // Kategoriler
                Column(
                  children: [
                    _buildCategoryItem('MDF Lam', 'mdf_lam', Icons.view_module),
                    _buildCategoryItem('Panel', 'panel', Icons.aspect_ratio),
                    _buildCategoryItem('Sunta', 'sunta', Icons.grid_view),
                    _buildCategoryItem('OSB', 'osb', Icons.layers),
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
                _buildAdItem(
                  'Son kalite MDF her ölçüde vardır!! Fırsatı Kaçırma',
                  '850 TL',
                ),
                _buildAdItem(
                  'Son kalite MDF her ölçüde vardır!! Fırsatı Kaçırma',
                  '850 TL',
                ),
                _buildAdItem(
                  'Son kalite MDF her ölçüde vardır!! Fırsatı Kaçırma',
                  '850 TL',
                ),
                Divider(),
                // Son Gezindiğiniz İlanlar
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    'Son Gezindiğiniz İlanlar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                _buildAdItem(
                  'Son kalite MDF her ölçüde vardır!! Fırsatı Kaçırma',
                  '850 TL',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
      String title, String collectionName, IconData icon) {
    final count = _categoryCounts[collectionName] ?? 0;

    return ListTile(
      leading: Icon(icon, size: 40, color: Colors.blueAccent),
      title: Text(title),
      trailing: Text('($count) >'),
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

  Widget _buildAdItem(String title, String price) {
    return ListTile(
      leading: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: Text(
        price,
        style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
      ),
      onTap: () {},
    );
  }
}
