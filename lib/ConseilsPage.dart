import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConseilsPage extends StatefulWidget {
  const ConseilsPage({Key? key}) : super(key: key);

  @override
  State<ConseilsPage> createState() => _ConseilsPageState();
}

class _ConseilsPageState extends State<ConseilsPage> {
  List<dynamic> conseils = [];

  @override
  void initState() {
    super.initState();
    fetchConseils();
  }

  Future<void> fetchConseils() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/api/conseils'));
    if (response.statusCode == 200) {
      setState(() {
        conseils = json.decode(response.body);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Conseils", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF5A1F35),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        itemCount: conseils.length,
        itemBuilder: (context, index) {
          final conseil = conseils[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text(conseil['titre'] ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(conseil['contenu'] ?? ''),
            ),
          );
        },
      ),
    );
  }
}
