import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConditionsAdminPage extends StatefulWidget {
  @override
  _ConditionsAdminPageState createState() => _ConditionsAdminPageState();
}

class _ConditionsAdminPageState extends State<ConditionsAdminPage> {
  List<dynamic> conditions = [];

  @override
  void initState() {
    super.initState();
    fetchConditions();
  }

  Future<void> fetchConditions() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/conditions'));
    if (response.statusCode == 200) {
      setState(() {
        conditions = json.decode(response.body);
      });
    }
  }

  Future<void> deleteCondition(String id) async {
    await http.delete(Uri.parse('http://10.0.2.2:3000/conditions/$id'));
    fetchConditions();
  }

  void showEditDialog(Map condition) {
    TextEditingController controller = TextEditingController(text: condition['text']);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Modifier la condition'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () async {
              await http.put(
                Uri.parse('http://10.0.2.2:3000/conditions/${condition['_id']}'),
                headers: {'Content-Type': 'application/json'},
                body: json.encode({'text': controller.text}),
              );
              Navigator.pop(context);
              fetchConditions();
            },
            child: Text('Modifier'),
          ),
        ],
      ),
    );
  }

  void showAddDialog() {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Ajouter une nouvelle condition'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () async {
              await http.post(
                Uri.parse('http://10.0.2.2:3000/conditions'),
                headers: {'Content-Type': 'application/json'},
                body: json.encode({'text': controller.text}),
              );
              Navigator.pop(context);
              fetchConditions();
            },
            child: Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Conditions du règlement')),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddDialog,
        child: Icon(Icons.add),
        backgroundColor: Color(0xFFB57D7F),
      ),
      body: ListView.builder(
        itemCount: conditions.length,
        itemBuilder: (context, index) {
          final condition = conditions[index];
          return Card(
            color: Color(0xFFF0E6E7),
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text(condition['text']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: Icon(Icons.edit, color: Colors.blue), onPressed: () => showEditDialog(condition)),
                  IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => deleteCondition(condition['_id'])),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
