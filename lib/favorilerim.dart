import 'package:flutter/material.dart';

class FavorilerimPage extends StatelessWidget {
  final List<String> favoriler; // Favorilere eklenen ilanlar listesi

  const FavorilerimPage({Key? key, required this.favoriler}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Favorilerim",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: favoriler.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border,
                      size: 100, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    "Favorileriniz boş",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Henüz favorilere ilan eklemediniz.",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: favoriler.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.pink.shade50,
                        child: const Icon(Icons.favorite, color: Colors.pink),
                      ),
                      title: Text(
                        favoriler[index],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // Favoriden silme işlemi
                          debugPrint(
                              "${favoriler[index]} favorilerden kaldırıldı");
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
