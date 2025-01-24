import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SonYorumlar extends StatefulWidget {
  final String ilanId;

  const SonYorumlar({Key? key, required this.ilanId}) : super(key: key);

  @override
  _SonYorumlarState createState() => _SonYorumlarState();
}

class _SonYorumlarState extends State<SonYorumlar> {
  late List<Map<String, dynamic>> comments = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Son Yorumlar",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 20),
        FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('comments')
              .where('ilanId', isEqualTo: widget.ilanId)
              .orderBy('timestamp', descending: true)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Hata: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  'Henüz yorum yapılmamış.',
                  style: TextStyle(
                      color: Colors.orange.shade500,
                      fontSize: 14,
                      fontStyle: FontStyle.italic),
                ),
              );
            }

            comments = snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return {
                'id': doc.id,
                'userName': data['userName'] ?? 'Bilinmeyen Kullanıcı',
                'comment': data['comment'] ?? 'Yorum yok',
                'timestamp': data['timestamp'] as Timestamp?,
                'hasReply': data['hasReply'] ?? false,
              };
            }).toList();

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                final userName = comment['userName'];
                final commentText = comment['comment'];
                late DateTime timestamp;
                if (comment['timestamp'] != null) {
                  timestamp = (comment['timestamp'] as Timestamp).toDate();
                } else {
                  timestamp = DateTime.now();
                }
                final formattedDate =
                    DateFormat('d MMM yyyy, HH:mm').format(timestamp);
                final hasReply = comment['hasReply'];

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.orange.shade300,
                            child: Text(
                              userName[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  formattedDate,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 48),
                        child: Text(
                          commentText,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: TextButton(
                          onPressed: () {
                            _showReplyModal(comment['id']);
                          },
                          child: const Text(
                            "Yanıtla",
                            style: TextStyle(color: Colors.blue, fontSize: 12),
                          ),
                        ),
                      ),
                      if (hasReply)
                        TextButton(
                          onPressed: () {
                            _showReplies(context, comment['id']);
                          },
                          child: const Text(
                            "Yanıtları Göster",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      const Divider(),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  void _showReplyModal(String commentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController replyController = TextEditingController();
        return AlertDialog(
          title: const Text("Yanıt Yaz"),
          content: TextField(
            controller: replyController,
            decoration: const InputDecoration(
              hintText: "Yanıtınızı yazın...",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (replyController.text.isNotEmpty) {
                  _addReply(commentId, replyController.text);
                  Navigator.of(context).pop(); // Modalı kapat
                }
              },
              child: const Text("Gönder"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Modalı kapat
              },
              child: const Text("İptal"),
            ),
          ],
        );
      },
    );
  }

  void _addReply(String commentId, String replyText) async {
    if (replyText.isNotEmpty) {
      await FirebaseFirestore.instance.collection('replys').add({
        'parentCommentId': commentId,
        'replyText': replyText,
        'timestamp': FieldValue.serverTimestamp(),
        'userName': 'Mevcut Kullanıcı', // Kullanıcı adını dinamik olarak alın
      });

      await FirebaseFirestore.instance
          .collection('comments')
          .doc(commentId)
          .update({
        'hasReply': true,
      });
    }
  }

  void _showReplies(BuildContext context, String commentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Yanıtlar"),
          content: FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('replys')
                .where('parentCommentId', isEqualTo: commentId)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Hata: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Text('Henüz yanıt yok.');
              }

              final replies = snapshot.data!.docs;

              return ListView.builder(
                shrinkWrap: true,
                itemCount: replies.length,
                itemBuilder: (context, index) {
                  final reply = replies[index];
                  final replyText = reply['replyText'] ?? 'Yanıt yok';
                  final replyUserName =
                      reply['userName'] ?? 'Bilinmeyen Kullanıcı';

                  return ListTile(
                    title: Text(replyUserName),
                    subtitle: Text(replyText),
                  );
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Kapat"),
            ),
          ],
        );
      },
    );
  }
}
