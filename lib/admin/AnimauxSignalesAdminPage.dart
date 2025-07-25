import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

class AnimauxSignalesAdminPage extends StatefulWidget {
  @override
  _AnimauxSignalesAdminPageState createState() => _AnimauxSignalesAdminPageState();
}

class _AnimauxSignalesAdminPageState extends State<AnimauxSignalesAdminPage> {
  List<dynamic> animaux = [];
  String selectedType = ''; // '' = tous les types

  final Color lightPink = Color(0xFFE4CFC8);
  final Color mediumBrown = Color(0xFFB57D7F);
  final Color darkBrown = Color(0xFF5A1F35);
  final Color phoneBlue = Colors.blue;  // لون الرقم

  @override
  void initState() {
    super.initState();
    fetchAnimaux();
  }

  Future<void> fetchAnimaux() async {
    final url = Uri.parse('http://10.0.2.2:3000/api/signal/signalements');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        animaux = json.decode(response.body);
      });
    } else {
      print('Erreur lors de la récupération des animaux');
    }
  }

  Future<void> deleteAnimal(String id) async {
    final response = await http.delete(
      Uri.parse('http://10.0.2.2:3000/api/signal/signalements/$id'),
    );

    if (response.statusCode == 200) {
      setState(() {
        animaux.removeWhere((animal) => animal['_id'] == id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Animal supprimé avec succès')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression')),
      );
    }
  }

  List<dynamic> getFilteredAnimaux() {
    if (selectedType == '') return animaux;
    return animaux.where((a) =>
    a['typeAnimal'] != null &&
        a['typeAnimal'].toString().toLowerCase() == selectedType.toLowerCase()).toList();
  }

  // دالة لفتح تطبيق الاتصال
  void _launchCaller(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de lancer l\'appel')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredAnimaux = getFilteredAnimaux();

    return Scaffold(
      backgroundColor: mediumBrown,
      appBar: AppBar(
        backgroundColor: darkBrown,
        title: Text("Animaux Signalés", style: TextStyle(color: lightPink)),
        iconTheme: IconThemeData(color: lightPink),
      ),
      body: Column(
        children: [
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilterChip(
                label: Text("Tous"),
                selected: selectedType == '',
                onSelected: (_) => setState(() => selectedType = ''),
                selectedColor: darkBrown,
                labelStyle: TextStyle(
                    color: selectedType == '' ? lightPink : Colors.black),
              ),
              SizedBox(width: 12),
              FilterChip(
                label: Text("Chats"),
                selected: selectedType == 'Chat',
                onSelected: (_) => setState(() => selectedType = 'Chat'),
                selectedColor: darkBrown,
                labelStyle: TextStyle(
                    color: selectedType == 'Chat' ? lightPink : Colors.black),
              ),
              SizedBox(width: 12),
              FilterChip(
                label: Text("Chiens"),
                selected: selectedType == 'Chien',
                onSelected: (_) => setState(() => selectedType = 'Chien'),
                selectedColor: darkBrown,
                labelStyle: TextStyle(
                    color: selectedType == 'Chien' ? lightPink : Colors.black),
              ),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: filteredAnimaux.isEmpty
                ? Center(child: Text("Aucun animal trouvé", style: TextStyle(color: lightPink)))
                : ListView.builder(
              itemCount: filteredAnimaux.length,
              itemBuilder: (context, index) {
                final animal = filteredAnimaux[index];
                String imageUrl = animal['image'] ?? '';
                if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
                  imageUrl = 'http://10.0.2.2:3000$imageUrl';
                }

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: lightPink,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (animal['image'] != null)
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                          child: Image.network(
                            imageUrl,
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Type: ${animal['typeAnimal'] ?? ''}",
                                  style: TextStyle(fontWeight: FontWeight.bold, color: darkBrown),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text("Confirmation"),
                                        content: Text("Voulez-vous vraiment supprimer cet animal signalé ?"),
                                        actions: [
                                          TextButton(
                                            child: Text("Annuler"),
                                            onPressed: () => Navigator.pop(context),
                                          ),
                                          TextButton(
                                            child: Text("OK", style: TextStyle(color: Colors.red)),
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              await deleteAnimal(animal['_id']);
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 6),
                            Text("Description: ${animal['description'] ?? ''}", style: TextStyle(color: darkBrown)),
                            Text("Adresse: ${animal['adresse'] ?? ''}", style: TextStyle(color: darkBrown)),

                            // هنا رقم الهاتف يكون clickable:
                            RichText(
                              text: TextSpan(
                                text: 'Téléphone: ',
                                style: TextStyle(color: darkBrown, fontSize: 16),
                                children: [
                                  TextSpan(
                                    text: animal['phone'] ?? '',
                                    style: TextStyle(
                                      color: phoneBlue,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        final phone = animal['phone'] ?? '';
                                        if (phone.isNotEmpty) {
                                          _launchCaller(phone);
                                        }
                                      },
                                  ),
                                ],
                              ),
                            ),


                            Text("Utilisateur: ${animal['fullName'] ?? ''}", style: TextStyle(color: darkBrown)),
                            Text("Email: ${animal['email'] ?? ''}", style: TextStyle(color: darkBrown)),
                            Text("UserType: ${animal['userType'] ?? ''}", style: TextStyle(color: darkBrown)),
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
