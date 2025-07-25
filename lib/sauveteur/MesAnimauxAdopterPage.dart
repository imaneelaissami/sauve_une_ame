import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MesAnimauxAdopterPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const MesAnimauxAdopterPage({Key? key, required this.userData}) : super(key: key);

  @override
  _MesAnimauxAdopterPageState createState() => _MesAnimauxAdopterPageState();
}

class _MesAnimauxAdopterPageState extends State<MesAnimauxAdopterPage> {
  List<dynamic> animaux = [];
  String selectedType = 'Chat';

  final Color lightPink = Color(0xFFE4CFC8);
  final Color mediumBrown = Color(0xFFB57D7F);
  final Color darkBrown = Color(0xFF5A1F35);

  @override
  void initState() {
    super.initState();
    fetchAnimaux();
  }

  Future<void> fetchAnimaux() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/api/adoptants'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        List<dynamic> filtered = data.where((item) =>
        (item['type']?.toLowerCase() == selectedType.toLowerCase()) &&
            (item['userType']?.toLowerCase() == 'sauveteuruser') &&
            (item['email']?.toLowerCase()?.trim() == widget.userData['email']?.toLowerCase()?.trim())
        ).toList();

        setState(() {
          animaux = filtered;
        });
      } else {
        print('Erreur lors du chargement: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur: $e');
    }
  }

  Future<void> deleteAnimal(String id) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmation'),
        content: Text('Voulez-vous vraiment supprimer cet animal ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('OK')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final response = await http.delete(Uri.parse('http://10.0.2.2:3000/api/adoptants/$id'));
        if (response.statusCode == 200) {
          fetchAnimaux();
        } else {
          print('Erreur de suppression: ${response.statusCode}');
        }
      } catch (e) {
        print('Erreur: $e');
      }
    }
  }

  void openEditDialog(Map<String, dynamic> animal) {
    TextEditingController descriptionCtrl = TextEditingController(text: animal['description']);
    TextEditingController adresseCtrl = TextEditingController(text: animal['adresse']);
    TextEditingController phoneCtrl = TextEditingController(text: animal['phone']);
    TextEditingController problemeCtrl = TextEditingController(text: animal['probleme']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier Animal'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: descriptionCtrl, decoration: InputDecoration(labelText: 'Description')),
              TextField(controller: adresseCtrl, decoration: InputDecoration(labelText: 'Adresse')),
              TextField(controller: phoneCtrl, decoration: InputDecoration(labelText: 'Téléphone')),
              TextField(controller: problemeCtrl, decoration: InputDecoration(labelText: 'Problème')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Annuler')),
          TextButton(
            onPressed: () async {
              final updated = {
                'description': descriptionCtrl.text,
                'adresse': adresseCtrl.text,
                'phone': phoneCtrl.text,
                'probleme': problemeCtrl.text,
              };
              try {
                final response = await http.put(
                  Uri.parse('http://10.0.2.2:3000/api/adoptants/${animal['_id']}'),
                  headers: {'Content-Type': 'application/json'},
                  body: json.encode(updated),
                );
                if (response.statusCode == 200) {
                  fetchAnimaux();
                  Navigator.pop(context);

                  // 🟢 SnackBar ici
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(
                      content: Text('✅ Sauvegarde réussie'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else {
                  print('Erreur modification: ${response.statusCode}');
                }

              } catch (e) {
                print('Erreur: $e');
              }
            },
            child: Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }

  String formatDate(String isoDate) {
    try {
      DateTime dateTime = DateTime.parse(isoDate).toLocal();
      return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "Date invalide";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightPink,
      appBar: AppBar(
        title: Text("Mes animaux à adopter", style: TextStyle(color: lightPink)),
        backgroundColor: darkBrown,
        iconTheme: IconThemeData(color: lightPink),
      ),
      body: Column(
        children: [
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilterButton(
                label: "Chats",
                icon: Icons.pets,
                color: mediumBrown,
                selected: selectedType == "Chat",
                onTap: () {
                  setState(() {
                    selectedType = "Chat";
                  });
                  fetchAnimaux();
                },
              ),
              SizedBox(width: 15),
              FilterButton(
                label: "Chiens",
                icon: Icons.pets,
                color: mediumBrown,
                selected: selectedType == "Chien",
                onTap: () {
                  setState(() {
                    selectedType = "Chien";
                  });
                  fetchAnimaux();
                },
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: animaux.length,
              itemBuilder: (context, index) {
                var animal = animaux[index];
                return Card(
                  margin: EdgeInsets.all(12),
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      animal['image'] != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.network(
                          'http://10.0.2.2:3000${animal['image']}',
                          height: 140,
                          width: 140,
                          fit: BoxFit.cover,
                        ),
                      )
                          : SizedBox(),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Description: ${animal['description'] ?? ''}", style: TextStyle(fontSize: 16, color: darkBrown)),
                            Text("Sexe: ${animal['sex'] ?? ''}"),
                            Text("Problème: ${animal['probleme'] ?? 'Aucun'}"),
                            Text("Adresse: ${animal['adresse'] ?? ''}"),
                            Text("Téléphone: ${animal['phone'] ?? ''}"),
                            Text("Proposé par vous: ${animal['fullName'] ?? ''}"),
                            Text("Date: ${formatDate(animal['dateAdoption'] ?? '')}"),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: mediumBrown),
                                  onPressed: () => openEditDialog(animal),

                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => deleteAnimal(animal['_id']),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const FilterButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: selected ? color : Colors.grey[300],
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(icon, color: Colors.black),
      label: Text(label, style: TextStyle(color: Colors.black)),
      onPressed: onTap,
    );
  }
}
