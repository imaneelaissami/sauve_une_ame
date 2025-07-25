import 'package:flutter/material.dart';
import 'notification_service.dart';

class UserNotificationsPage extends StatefulWidget {
  final String email;

  const UserNotificationsPage({Key? key, required this.email}) : super(key: key);

  @override
  _UserNotificationsPageState createState() => _UserNotificationsPageState();
}

class _UserNotificationsPageState extends State<UserNotificationsPage> {
  late Future<List<dynamic>> _futureNotifications;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    _futureNotifications = fetchNotifications(widget.email);
  }

  Future<void> _deleteNotification(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer cette notification ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Supprimer')),
        ],
      ),
    );

    if (confirm == true) {
      final success = await deleteNotification(id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Notification supprimée'),
            backgroundColor: Colors.green, // اللون الأخضر
            duration: Duration(seconds: 2),),
        );
        setState(() {
          _loadNotifications(); // إعادة تحميل البيانات بعد الحذف
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la suppression')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: TextStyle(color: Colors.white), // لون النص الأبيض
        ),
        iconTheme: IconThemeData(color: Colors.white), // السهم الأبيض
        backgroundColor: Color(0xFF5A1F35), // لون الخلفية
      ),

      body: FutureBuilder<List<dynamic>>(
        future: _futureNotifications,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucune notification'));
          } else {
            final notifications = snapshot.data!;
            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  color: Colors.white, // لون الخلفية ديال الكارد
                  child: ListTile(
                    leading: Icon(Icons.notifications, color: Colors.grey), // باش يبان مزيان فوق الخلفية
                    subtitle: Text(
                      notif['message'] ?? '',
                      style: TextStyle(color: Colors.black), // لون الوصف
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red), // زر الحذف بالأبيض
                      onPressed: () => _deleteNotification(notif['_id']),
                    ),
                  ),
                );

              },
            );
          }
        },
      ),
    );
  }
}
