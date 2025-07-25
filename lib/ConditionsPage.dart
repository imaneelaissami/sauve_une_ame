import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConditionsPage extends StatefulWidget {
  @override
  _ConditionsPageState createState() => _ConditionsPageState();
}

class _ConditionsPageState extends State<ConditionsPage> {
  List<String> conditions = [];

  @override
  void initState() {
    super.initState();
    fetchConditions();
  }

  Future<void> fetchConditions() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/conditions'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          conditions = data.map((item) => item['text'] as String).toList();
        });
      } else {
        print('Erreur de chargement: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Conditions d'utilisation",
          style: TextStyle(color: Colors.white), // لون النص الأبيض
        ),
        iconTheme: IconThemeData(color: Colors.white), // السهم الأبيض
        backgroundColor: Color(0xFF5A1F35), // لون الخلفية
      ),

      body: conditions.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: conditions.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ListTile(
              leading: Icon(Icons.rule, color: Colors.brown),
              title: Text(conditions[index]),
            ),
          );
        },
      ),
    );
  }
}
