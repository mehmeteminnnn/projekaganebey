import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Depot/models/ilan_model.dart';
import 'package:Depot/services/firestore_services.dart';
import 'package:Depot/widgets/ilan_card.dart';

class OlmayanIlanlarimPage extends StatefulWidget {
  final String? id;
  const OlmayanIlanlarimPage({Key? key, this.id}) : super(key: key);
  @override
  _OlmayanIlanlarimPageState createState() => _OlmayanIlanlarimPageState();
}

class _OlmayanIlanlarimPageState extends State<OlmayanIlanlarimPage> {
  final FirestoreService _firestoreService = FirestoreService();
  List<IlanModel> _ilanlar = [];
  bool _isLoading = true;
  // Kullanıcının ilanlarını getiren fonksiyon
  Future<void> fetchUserYayindaOlmayanIlanlar() async {
    try {
      // Firebase Authentication'dan geçerli kullanıcının ID'sini alıyoruz
      String? currentUserId =
          widget.id; //?? FirebaseAuth.instance.currentUser?.uid;

      if (currentUserId == null) {
        setState(() {
          _isLoading = false;
        });
        // Kullanıcı giriş yapmamış, hatayı burada gösterebilirsiniz
        print("Kullanıcı giriş yapmamış");
        return;
      }

      // Firestore'dan kullanıcı bilgilerini alıyoruz
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId) // Kullanıcının ID'siyle ilgili veriyi alıyoruz
          .get();
      debugPrint('currentUserId: $currentUserId');

      if (!userDoc.exists) {
        setState(() {
          _isLoading = false;
        });
        // Kullanıcı bulunamadı
        print("Kullanıcı bulunamadı");
        return;
      }

      // Kullanıcının ilan ID listesi, null kontrolü yapılmalı
      List<String> ilanIdList =
          List<String>.from(userDoc.data()?['yayindaOlmayan'] ?? []);

      if (ilanIdList.isNotEmpty) {
        // İlanları alıyoruz
        List<IlanModel> ilanlar =
            await _firestoreService.fetchIlanlarByYayindaOlmayan(ilanIdList);
        setState(() {
          _ilanlar = ilanlar;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error fetching user ilanlar: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserYayindaOlmayanIlanlar(); // Sayfa yüklendiğinde ilanları çekiyoruz
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Yayında Olmayan İlanlarım',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Yükleniyor göstergesi
          : _ilanlar.isEmpty
              ? const Center(child: Text("Henüz ilanınız yok."))
              : GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                    childAspectRatio: 1,
                  ),
                  itemCount: _ilanlar.length,
                  itemBuilder: (context, index) {
                    var ilan = _ilanlar[index];
                    return buildIlanCard(
                      yayindaOlmayan: true,
                      kendiIlanim: true,
                      baslik: ilan.baslik,
                      fiyat: ilan.fiyat,
                      resimUrl: ilan.resimler?.isNotEmpty == true
                          ? ilan.resimler![0]
                          : null,
                      ilanID: ilan.id!,
                      context: context,
                    );
                  },
                ),
    );
  }
}
