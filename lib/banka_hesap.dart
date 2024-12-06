import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BankaHesapBilgileriPage extends StatefulWidget {
  final String userId;

  BankaHesapBilgileriPage({required this.userId});

  @override
  _BankaHesapBilgileriPageState createState() =>
      _BankaHesapBilgileriPageState();
}

class _BankaHesapBilgileriPageState extends State<BankaHesapBilgileriPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _faturaAdresiController = TextEditingController();
  final TextEditingController _sehirController = TextEditingController();
  final TextEditingController _ilceController = TextEditingController();
  final TextEditingController _mahalleController = TextEditingController();
  final TextEditingController _tcController = TextEditingController();
  final TextEditingController _ibanAdController = TextEditingController();
  final TextEditingController _ibanSoyadController = TextEditingController();
  final TextEditingController _ibanController = TextEditingController();

  Future<void> _kaydet() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('bankDetails')
            .add({
          'faturaAdresi': _faturaAdresiController.text,
          'sehir': _sehirController.text,
          'ilce': _ilceController.text,
          'mahalle': _mahalleController.text,
          'tcKimlikNo': _tcController.text,
          'ibanAd': _ibanAdController.text,
          'ibanSoyad': _ibanSoyadController.text,
          'iban': _ibanController.text,
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bilgiler başarıyla kaydedildi!')),
        );
        _formKey.currentState!.reset();
        _clearControllers();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bir hata oluştu: $e')),
        );
      }
    }
  }

  void _clearControllers() {
    _faturaAdresiController.clear();
    _sehirController.clear();
    _ilceController.clear();
    _mahalleController.clear();
    _tcController.clear();
    _ibanAdController.clear();
    _ibanSoyadController.clear();
    _ibanController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Banka Hesap Bilgileri',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                controller: _faturaAdresiController,
                label: 'Fatura Adresi',
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _sehirController,
                      label: 'Şehir',
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _ilceController,
                      label: 'İlçe',
                    ),
                  ),
                ],
              ),
              _buildTextField(
                controller: _mahalleController,
                label: 'Mahalle',
              ),
              _buildTextField(
                controller: _tcController,
                label: 'T.C Kimlik No.',
                keyboardType: TextInputType.number,
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _ibanAdController,
                      label: 'IBAN Sahibinin Adı',
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _ibanSoyadController,
                      label: 'IBAN Sahibinin Soyadı',
                    ),
                  ),
                ],
              ),
              _buildTextField(
                controller: _ibanController,
                label: 'IBAN No.',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _kaydet,
                icon: Icon(Icons.save),
                label: Text('Kaydet'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label alanı boş bırakılamaz.';
          }
          return null;
        },
      ),
    );
  }
}
