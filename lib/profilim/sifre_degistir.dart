import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  String _oldPassword = '';
  String _newPassword = '';
  String _confirmPassword = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Şifre Değiştir'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Mevcut Şifre'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen mevcut şifrenizi girin';
                  }
                  return null;
                },
                onSaved: (value) {
                  _oldPassword = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Yeni Şifre'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen yeni şifrenizi girin';
                  } else if (value.length < 6) {
                    return 'Şifre en az 6 karakter olmalı';
                  }
                  return null;
                },
                onSaved: (value) {
                  _newPassword = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Yeni Şifre (Tekrar)'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen yeni şifrenizi tekrar girin';
                  } else if (value != _newPassword) {
                    return 'Şifreler uyuşmuyor';
                  }
                  return null;
                },
                onSaved: (value) {
                  _confirmPassword = value!;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Şifre değiştirme işlemini buradan gerçekleştirebilirsin
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Şifre başarıyla güncellendi')),
                    );
                  }
                },
                child: const Text('Şifreyi Güncelle'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
