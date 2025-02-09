import 'package:flutter/material.dart';
import 'package:Depot/models/notification_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<NotificationModel> notifications = [
    // Örnek bildirim verileri
    NotificationModel(
      title: 'Bugün eklenen yeni PVC ürünlerini keşfetmek için tıklayın 👉',
      body: 'Bugün eklenen yeni PVC ürünlerini keşfetmek için tıklayın 👉',
      date: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    NotificationModel(
      title: 'Laminant ürünlerde %10 indirim fırsatını kaçırmayın 👉',
      body: 'Laminant ürünlerde %10 indirim fırsatını kaçırmayın 👉',
      date: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    NotificationModel(
      title:
          '100 TL altı laminant ve PVC ürünlerde kargo bedava! Şimdi alışveriş yapın 👉',
      body:
          '100 TL altı laminant ve PVC ürünlerde kargo bedava! Şimdi alışveriş yapın 👉',
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    NotificationModel(
      title: 'En çok satan PVC modellerimiz stokta! Göz atmayı unutmayın 👉',
      body: 'En çok satan PVC modellerimiz stokta! Göz atmayı unutmayın 👉',
      date: DateTime.now().subtract(const Duration(days: 3)),
    ),
    NotificationModel(
      title:
          'Müşterilerimizin favori laminant tasarımları: Keşfetmek için tıkla 👉',
      body:
          'Müşterilerimizin favori laminant tasarımları: Keşfetmek için tıkla 👉',
      date: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  void addNotification(String title, String body) {
    notifications.add(NotificationModel(
      title: title,
      body: body,
      date: DateTime.now(),
    ));
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      addNotification(
        message.notification?.title ?? 'Yeni Bildirim',
        message.notification?.body ?? '',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Bildirimler",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return NotificationCard(notification: notification);
        },
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;

  NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.pink[100],
            child: const Icon(
              Icons.campaign,
              color: Colors.pink,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(notification.date),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final Duration diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} dk önce';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} saat önce';
    } else {
      return '${diff.inDays} gün önce';
    }
  }
}
