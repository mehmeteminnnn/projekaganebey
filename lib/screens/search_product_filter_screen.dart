import 'package:flutter/material.dart';
import 'package:projekaganebey/services/firestore_services.dart';

class FilterProductPage extends StatefulWidget {
  final String category; // Örneğin "mdf"
  final String title; // Örneğin "MDF LAM"

  const FilterProductPage(
      {Key? key, required this.category, required this.title})
      : super(key: key);

  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterProductPage> {
  final FirestoreService _firestoreService = FirestoreService();

  Map<String, int> _counts = {};
  bool _isLoading = true;

  static const List<String> producers = [
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
    'Seloit',
    "Diğer"
  ];

  @override
  void initState() {
    super.initState();
    _fetchCounts();
  }

  Future<void> _fetchCounts() async {
    Map<String, int> counts = {};
    for (String producer in producers) {
      int count = await _firestoreService.getDocumentCountByProducer(
          widget.category, producer);
      counts[producer] = count;
    }
    setState(() {
      _counts = counts;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title.toUpperCase()} Filtreleri'),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                ListTile(
                  title:
                      Text('Tüm "${widget.category.toUpperCase()}" İlanları'),
                  trailing: Text(
                    '(${_counts.values.fold(0, (sum, count) => sum + count)}) >',
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ),
                Divider(),
                ...producers.map((producer) {
                  return ListTile(
                    title: Text(producer),
                    trailing: Text('(${_counts[producer] ?? 0}) >'),
                    onTap: () {
                      // Tıklanan üreticinin detaylarına yönlendirme yapılabilir
                    },
                  );
                }).toList(),
              ],
            ),
    );
  }
}
