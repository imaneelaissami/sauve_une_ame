import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class SendNotificationPage extends StatefulWidget {
  final String email;  // بدل userEmail

  SendNotificationPage({required this.email});

  @override
  _SendNotificationPageState createState() => _SendNotificationPageState();
}

class _SendNotificationPageState extends State<SendNotificationPage> {
  final TextEditingController _messageController = TextEditingController();
  bool isSending = false;

  Future<void> sendNotification() async {
    setState(() => isSending = true);

    final response = await http.post(
      Uri.parse('http://10.0.2.2:3000/api/notifications/sendNotification'), // مسار API ديالك
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': widget.email,
        'message': _messageController.text,
      }),
    );

    setState(() => isSending = false);

    if (response.statusCode == 200) {
      Navigator.pop(context, true); // رجع للصفحة السابقة
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notification envoyée !')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec de l’envoi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Envoyer une notification')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("À: ${widget.email}"),
            SizedBox(height: 10),
            TextField(
              controller: _messageController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Écrire le message ici...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 26),
            ElevatedButton(
              onPressed: isSending ? null : sendNotification,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFB57D7F), // اللون مباشرة
                foregroundColor: Colors.black, // لون النص
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(isSending ? 'Envoi en cours...' : 'Envoyer'),
            ),

          ],
        ),
      ),
    );
  }
}
