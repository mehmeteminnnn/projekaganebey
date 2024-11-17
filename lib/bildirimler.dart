import 'package:flutter/material.dart';

class NotificationModel {
  final String title;
  final String description;
  final DateTime date;

  NotificationModel(
      {required this.title, required this.description, required this.date});
}

class NotificationsPage extends StatelessWidget {
  // Örnek bildirim verileri
  final List<NotificationModel> notifications = [
    NotificationModel(
      title: 'Yeni İlan Yayınlandı',
      description: 'Yeni bir ilan yayına alındı. Başvurunuzu yapabilirsiniz.',
      date: DateTime.now().subtract(Duration(minutes: 5)),
    ),
    NotificationModel(
      title: 'Hesabınız Onaylandı',
      description: 'Hesabınız başarıyla onaylandı, artık ilan verebilirsiniz.',
      date: DateTime.now().subtract(Duration(hours: 1)),
    ),
    NotificationModel(
      title: 'Yeni Mesajınız Var',
      description: 'Bir kullanıcı size yeni bir mesaj gönderdi.',
      date: DateTime.now().subtract(Duration(days: 1)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
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
    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(13.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              notification.description,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Text(
              '${notification.date.hour}:${notification.date.minute}, ${notification.date.day}/${notification.date.month}/${notification.date.year}',
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }
}
