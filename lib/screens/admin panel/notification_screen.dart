import 'package:flutter/material.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();
  String? successMessage;

  // Bu fonksiyon, Firebase Cloud Messaging için OAuth2 Bearer Token alır
  Future<String> getAccessToken() async {
    final serviceAccountCredentials = ServiceAccountCredentials.fromJson({
      // JSON dosyanızdaki bilgileri buraya ekleyin

      "type": "service_account",
      "project_id": "kaganbey",
      "private_key_id": "bdf39fa90e56cd4014fa07d1df4c1a527d86e907",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDepkMfpXRQqk6p\narFpxVLzrxAa4w0dB22+3ZewQD9kWKgCoYYRo9xA5WfDk2pK7lITtjULPmdTdKQt\n0OjKaovOdpZCGiwNy6j+dxxJ/oGoeIVF9ps8KvFU9oZuqYGti7vsqkUduyWiV608\nIVzC5geDuU5qCbAraLTXTqHibh9P+85tIpPqELePS8r1LV+vjoo/47bCV1WWrSGG\ng6GK1qMZTow4QyFRU0z2ksiCIeJdhBkqN55mhwePIq6fHpIpZP3ldACrF+ZUTjgJ\nO2ba4gcAOP7Ise2pVzeNN90/82GqZ3+Jm8OTtKHSsm+fRkt9B7q7MziEyJRMUb+V\naeOXIBkTAgMBAAECggEAHuCo+Me941KoeRdfsQmuxjZ2QdGmPRXi0vBb++iqbJ9c\n9uHGvEXgzavi9ufH+x9Ps7B2bRpDmHqEgF7IwgsCW5OXpWWIIYZSkq5wdmnnj7aI\nfm+ZD2rshXoboleQsUGVQi5KSo7B7+CVQ6cO0cVhWmkbEQVJ8M3jHTmoUBox7n9S\nQZ5UgA1pV99PFFiv25iV4fg3f4KQEBbWDP/eslsuNvtViJdjkFZEy5NtVbpdoriX\nuEIGJMBhBTEiLBetp2uKP6m2Oc2nXToGnDaEh2xbLC1ojRWRfda/bLKKDQDkx3Yr\nLvYXgp8vRVl9Y2xFnVR7yV4T9dLjbRTFRg2KAcWGEQKBgQD+rNwvFRIFfaj7ZSeG\n6vtHQyG5K5X05Hwt72rMr4n0/zqpa5SKcl1+tSIE8Jhm3JHftIcpBSQtH8G9wzp6\n24gHVNKvnaXzwHGBoQDwCYLqyuTxCAnsziIUYUn3W8hH7BDCwVc5HfLIBgFSbHjG\nwtZQe13iq4vBq+102ShxgYj+cQKBgQDfzsE5bkxCbY2HGGp9Mg4YmGXh7+jpdWWW\nAKOLrbcy5uqrKxHj8luEAP+ybysYiw5jSoRyUQyJ+cUlkhz8J1SoBZelAvOp0VMM\nivHQ61NPeZeTiK+qy95wOiPo18Wh5kCK+vp0XeZDe9eXkx0H/7DhAgai2orNyspx\nC/QBSuFZwwKBgQDFkCNfAuFwEQM9wkLfjvpPVeybUQyLZZRPriMTljlXLYe8VhBt\nNjsBSFKTsnEHmqQu/kS7tZlSyAfrxb9f/12PEmY+hfVvGiLzhIrNqxM8QRlJQgsx\nANe/J5nRognEgYSfEI0xaeIk+UOdRTiMOCk5VfqHFLzeCRm0Q6H0K6CygQKBgQCM\ngmirHsU/2znEfB63FQrmhB9Ktu06TNsHTsVetyRSD8l6xyKHQqwT9vCRXNvon7zb\nt3fpsVq28RnF2bLa1/J9Pm2TSoQhtGp4cG8a4/M87TCtjl4DU9UGDmpnD7hjSYRx\n/Nnq3tzmt0SGQ/UxBWVODpCOA7irNMreKEv718AdMwKBgEnFY3TwK8qzepCbJ6og\ncAt8jpTuJEHfqwEgF4GIEWzdsyJ0Kc3JMKp8oU1KTNJmSWbVUvTBY2dHmwy0XUet\nD7cZPZAtOffGymI1EgYg9zeb54sRm1JhS7DKvK8MMc/nPwu20sv7rI9q4MNIZ4kC\n5yxcWeC20lV2k4jqM3G2AOT4\n-----END PRIVATE KEY-----\n",
      "client_email":
          "firebase-adminsdk-46nfb@kaganbey.iam.gserviceaccount.com",
      "client_id": "105894327811642900545",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-46nfb%40kaganbey.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    });

    const scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
    final authClient =
        await clientViaServiceAccount(serviceAccountCredentials, scopes);
    return authClient.credentials.accessToken.data;
  }

  // Bildirim gönderme fonksiyonu
  Future<void> sendNotification(String title, String body) async {
    try {
      final accessToken = await getAccessToken(); // OAuth2 token almak

      // Firestore'dan tüm token'ları al
      final userTokensSnapshot =
          await FirebaseFirestore.instance.collection('user_tokens').get();
      final tokens =
          userTokensSnapshot.docs.map((doc) => doc['token'] as String).toList();

      for (String token in tokens) {
        final String apiUrl =
            'https://fcm.googleapis.com/v1/projects/kaganbey/messages:send';

        final Map<String, dynamic> message = {
          'message': {
            'notification': {
              'title': title,
              'body': body,
            },
            'token': token, // Her bir kullanıcı token'ına bildirim gönder
          },
        };

        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(message),
        );

        if (response.statusCode != 200) {
          debugPrint("Bildirim gönderme hatası: ${response.body}");
        }
      }

      setState(() {
        successMessage = "Bildirimler başarıyla gönderildi!";
      });
      titleController.clear();
      bodyController.clear();
    } catch (error) {
      setState(() {
        successMessage = "Bir hata oluştu: $error";
        debugPrint("Bir hata oluştu: $error");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bildirim Gönder"),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: "Başlık",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.title),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: bodyController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: "Mesaj",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.message),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  sendNotification(titleController.text, bodyController.text);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Gönder",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              // Başarı mesajını göster
              if (successMessage != null)
                Text(
                  successMessage!,
                  style: const TextStyle(color: Colors.green, fontSize: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
