// file: services/notification_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<dynamic>> fetchNotifications(String email) async {
  final url = Uri.parse('http://10.0.2.2:3000/api/notifications/$email');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Erreur lors du chargement des notifications');
  }
}

Future<bool> deleteNotification(String id) async {
  final url = Uri.parse('http://10.0.2.2:3000/api/notifications/$id');

  final response = await http.delete(url);

  if (response.statusCode == 200) {
    return true;  // حذف ناجح
  } else {
    print('Erreur suppression: ${response.statusCode} ${response.body}');
    return false; // حذف فشل
  }
}

