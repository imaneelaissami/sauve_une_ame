import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminConseilsPage extends StatefulWidget {
  @override
  _AdminConseilsPageState createState() => _AdminConseilsPageState();
}

class _AdminConseilsPageState extends State<AdminConseilsPage> {
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
    } else {
      print('Erreur de chargement des conseils');
    }
  }

  Future<void> deleteConseil(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Confirmation'),
        content: Text('Voulez-vous vraiment supprimer ce conseil ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('OK', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final response = await http.delete(Uri.parse('http://10.0.2.2:3000/api/conseils/$id'));
      if (response.statusCode == 200) {
        fetchConseils();
      } else {
        print('Erreur suppression');
      }
    }
  }


  void showAddEditDialog({Map? conseil}) {
    final titreController = TextEditingController(text: conseil?['titre'] ?? '');
    final contenuController = TextEditingController(text: conseil?['contenu'] ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(conseil == null ? 'Ajouter un conseil' : 'Modifier le conseil'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: titreController, decoration: InputDecoration(labelText: 'Titre')),
              TextField(controller: contenuController, decoration: InputDecoration(labelText: 'Contenu')),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Annuler'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text('Enregistrer'),
            onPressed: () async {
              final data = {
                'titre': titreController.text,
                'contenu': contenuController.text,
              };
              if (conseil == null) {
                await http.post(
                  Uri.parse('http://10.0.2.2:3000/api/conseils'),
                  headers: {'Content-Type': 'application/json'},
                  body: json.encode(data),
                );
              } else {
                await http.put(
                  Uri.parse('http://10.0.2.2:3000/api/conseils/${conseil['_id']}'),
                  headers: {'Content-Type': 'application/json'},
                  body: json.encode(data),
                );
              }
              Navigator.pop(context);
              fetchConseils();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des conseils'),
        backgroundColor: Color(0xFF5A1F35),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddEditDialog(),
        child: Icon(Icons.add),
        backgroundColor: Colors.brown[400],
      ),
      body: ListView.builder(
        itemCount: conseils.length,
        itemBuilder: (context, index) {
          final conseil = conseils[index];
          return Card(
            margin: EdgeInsets.all(10),
            elevation: 4,
            child: ListTile(
              title: Text(conseil['titre'], style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(conseil['contenu']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: Icon(Icons.edit), onPressed: () => showAddEditDialog(conseil: conseil)),
                  IconButton(icon: Icon(Icons.delete), onPressed: () => deleteConseil(conseil['_id'])),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
