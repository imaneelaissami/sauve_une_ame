import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdoptedAnimalsPage extends StatefulWidget {
  @override
  _AdoptedAnimalsPageState createState() => _AdoptedAnimalsPageState();
}

class _AdoptedAnimalsPageState extends State<AdoptedAnimalsPage> {
  List<dynamic> adoptedAnimals = [];
  bool isLoading = true;

  String selectedType = ''; // '' تعني الكل، 'Chat' أو 'Chien' للتصفية

  final Color lightPink = const Color(0xFFE4CFC8);
  final Color mediumBrown = const Color(0xFFB57D7F);
  final Color darkBrown = const Color(0xFF5A1F35);

  @override
  void initState() {
    super.initState();
    fetchAdoptedAnimals();
  }

  Future<void> fetchAdoptedAnimals() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/api/adoptants'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          adoptedAnimals = data;
          isLoading = false;
        });
      } else {
        print('Erreur lors de la récupération des animaux');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Erreur: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteAdoptant(String id) async {
    try {
      final response = await http.delete(Uri.parse('http://10.0.2.2:3000/api/adoptants/$id'));
      if (response.statusCode == 200) {
        setState(() {
          adoptedAnimals.removeWhere((animal) => animal['_id'] == id);
        });
      } else {
        print('Erreur de suppression');
      }
    } catch (e) {
      print('Erreur: $e');
    }
  }

  Future<void> confirmDelete(String id) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmation'),
        content: Text('Voulez-vous vraiment supprimer cet animal ?'),
        actions: [
          TextButton(
            child: Text('Annuler'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('Supprimer'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await deleteAdoptant(id);
    }
  }

  // فلترة الحيوانات حسب النوع
  List<dynamic> getFilteredAnimals() {
    if (selectedType == '') return adoptedAnimals;
    return adoptedAnimals.where((animal) {
      final type = animal['typeAnimal'] ?? animal['type']; // حسب الاسم في الداتا
      return type.toString().toLowerCase() == selectedType.toLowerCase();
    }).toList();
  }

  Widget buildAnimalCard(animal) {
    String imageUrl = animal['image'] ?? '';
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      imageUrl = 'http://10.0.2.2:3000' + imageUrl;
    }

    return Card(
      color: lightPink,
      margin: EdgeInsets.all(10),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(imageUrl),
                radius: 30,
              ),
              title: Text(
                animal['type'] ?? animal['typeAnimal'] ?? 'Type inconnu',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Text("Sexe: ${animal['sex'] ?? ''}", style: TextStyle(color: Colors.black)),
                  Text("Problème: ${animal['probleme'] ?? 'Aucun'}", style: TextStyle(color: Colors.black)),
                  Text("Description: ${animal['description'] ?? ''}", style: TextStyle(color: Colors.black)),
                  SizedBox(height: 8),
                  Text("Nom d'utilisateur: ${animal['fullName']}", style: TextStyle(color: Colors.black)),
                  Text("Email: ${animal['email']}", style: TextStyle(color: Colors.black)),
                  Text("Téléphone: ${animal['phone']}", style: TextStyle(color: Colors.black)),
                  Text("Type utilisateur: ${animal['userType']}", style: TextStyle(color: Colors.black)),
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => confirmDelete(animal['_id']),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredAnimals = getFilteredAnimals();

    return Scaffold(
      backgroundColor: mediumBrown,
      appBar: AppBar(
        title: Text('Animaux à Adopter', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: darkBrown,
        elevation: 0,
      ),
      body: Column(
        children: [
          SizedBox(height: 15),
          // أزرار الفلترة حسب النوع
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilterChip(
                label: Text("Tous"),
                selected: selectedType == '',
                onSelected: (_) => setState(() => selectedType = ''),
                selectedColor: darkBrown,
                labelStyle: TextStyle(
                  color: selectedType == '' ? lightPink : Colors.black,
                ),
              ),
              SizedBox(width: 12),
              FilterChip(
                label: Text("Chats"),
                selected: selectedType == 'Chat',
                onSelected: (_) => setState(() => selectedType = 'Chat'),
                selectedColor: darkBrown,
                labelStyle: TextStyle(
                  color: selectedType == 'Chat' ? lightPink : Colors.black,
                ),
              ),
              SizedBox(width: 12),
              FilterChip(
                label: Text("Chiens"),
                selected: selectedType == 'Chien',
                onSelected: (_) => setState(() => selectedType = 'Chien'),
                selectedColor: darkBrown,
                labelStyle: TextStyle(
                  color: selectedType == 'Chien' ? lightPink : Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          // عرض القائمة
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredAnimals.isEmpty
                ? Center(child: Text('Aucun animal trouvé.', style: TextStyle(color: Colors.white)))
                : ListView.builder(
              itemCount: filteredAnimals.length,
              itemBuilder: (context, index) => buildAnimalCard(filteredAnimals[index]),
            ),
          ),
        ],
      ),
    );
  }
}
