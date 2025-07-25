import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MesSignalementsPage extends StatefulWidget {
  final String email;

  const MesSignalementsPage({Key? key, required this.email}) : super(key: key);

  @override
  _MesSignalementsPageState createState() => _MesSignalementsPageState();
}

class _MesSignalementsPageState extends State<MesSignalementsPage> {
  List<dynamic> allSignalements = [];
  String selectedType = 'Chat';
  int? editingIndex;

  final Color lightPink = Color(0xFFE4CFC8);
  final Color mediumBrown = Color(0xFFB57D7F);
  final Color darkBrown = Color(0xFF5A1F35);

  TextEditingController descriptionController = TextEditingController();
  TextEditingController adresseController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchSignalements();
  }

  Future<void> fetchSignalements() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/api/signal/signalements'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<dynamic> userSignalements = data.where((item) =>
        item['userType'] == 'normalUser' && item['email'] == widget.email).toList();

        setState(() {
          allSignalements = userSignalements;
        });
      } else {
        print('Erreur lors du chargement: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur: $e');
    }
  }

  void deleteSignalement(String id) async {
    final url = Uri.parse('http://10.0.2.2:3000/api/signal/signalements/$id');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      setState(() {
        allSignalements.removeWhere((element) => element['_id'] == id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signalement supprimé')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression')),
      );
    }
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
    List<dynamic> filtered = allSignalements.where((item) => item['typeAnimal'] == selectedType).toList();

    return Scaffold(
      backgroundColor: lightPink,
      appBar: AppBar(
        title: Text("Mes animaux signalés", style: TextStyle(color: lightPink)),
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
                onTap: () => setState(() => selectedType = "Chat"),
              ),
              SizedBox(width: 15),
              FilterButton(
                label: "Chiens",
                icon: Icons.pets,
                color: mediumBrown,
                selected: selectedType == "Chien",
                onTap: () => setState(() => selectedType = "Chien"),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                var animal = filtered[index];
                bool isEditing = editingIndex == index;

                if (isEditing) {
                  descriptionController.text = animal['description'] ?? '';
                  adresseController.text = animal['adresse'] ?? '';
                  phoneController.text = animal['phone'] ?? '';
                  fullNameController.text = animal['fullName'] ?? '';
                }

                return Card(
                  margin: EdgeInsets.all(12),
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                            isEditing
                                ? TextField(controller: descriptionController, decoration: InputDecoration(labelText: 'Description'))
                                : Text("Description: ${animal['description'] ?? ''}", style: TextStyle(fontSize: 16, color: darkBrown)),
                            SizedBox(height: 6),
                            isEditing
                                ? TextField(controller: adresseController, decoration: InputDecoration(labelText: 'Adresse'))
                                : Text("Adresse: ${animal['adresse'] ?? ''}", style: TextStyle(color: darkBrown)),
                            SizedBox(height: 6),
                            isEditing
                                ? TextField(controller: phoneController, decoration: InputDecoration(labelText: 'Téléphone'))
                                : Text("Téléphone: ${animal['phone'] ?? ''}", style: TextStyle(color: darkBrown)),
                            SizedBox(height: 6),
                            isEditing
                                ? TextField(controller: fullNameController, decoration: InputDecoration(labelText: 'Nom'))
                                : Text("Signalé par vous: ${animal['fullName'] ?? ''}", style: TextStyle(color: darkBrown)),
                            SizedBox(height: 6),
                            Text("Date: ${formatDate(animal['dateSignalement'])}", style: TextStyle(color: darkBrown)),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          isEditing
                              ? Row(
                            children: [
                              TextButton(
                                onPressed: () => setState(() => editingIndex = null),
                                child: Text('Annuler'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: darkBrown),
                                onPressed: () async {
                                  final updatedData = {
                                    "description": descriptionController.text,
                                    "adresse": adresseController.text,
                                    "phone": phoneController.text,
                                    "fullName": fullNameController.text,
                                  };
                                  final url = Uri.parse('http://10.0.2.2:3000/api/signal/signalements/${animal['_id']}');
                                  final response = await http.put(
                                    url,
                                    headers: {'Content-Type': 'application/json'},
                                    body: json.encode(updatedData),
                                  );
                                  if (response.statusCode == 200) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('✅ Sauvegarde réussie'),
                                        backgroundColor: Colors.green,
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                    setState(() {
                                      editingIndex = null;
                                    });
                                    fetchSignalements();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Erreur lors de la modification')),
                                    );
                                  }
                                },
                                child: Text('Enregistrer'),
                              ),
                            ],
                          )
                              : Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => setState(() => editingIndex = index),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Confirmation"),
                                        content: Text("Voulez-vous vraiment supprimer ce signalement ?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(),
                                            child: Text("Annuler"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              deleteSignalement(animal['_id']);
                                            },
                                            child: Text("OK", style: TextStyle(color: Colors.red)),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
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
