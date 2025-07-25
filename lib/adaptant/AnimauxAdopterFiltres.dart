import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

class AnimauxAdopterFiltres extends StatefulWidget {
  const AnimauxAdopterFiltres({Key? key}) : super(key: key);

  @override
  State<AnimauxAdopterFiltres> createState() => _AnimauxAdopterFiltresState();
}

class _AnimauxAdopterFiltresState extends State<AnimauxAdopterFiltres> {
  List<dynamic> animaux = [];
  String selectedType = "Chat";
  final Color lightPink = Color(0xFFE4CFC8);
  final Color mediumBrown = Color(0xFFB57D7F);
  final Color darkBrown = Color(0xFF5A1F35);

  @override
  void initState() {
    super.initState();
    fetchAnimaux();
  }

  Future<void> fetchAnimaux() async {
    final url = Uri.parse('http://10.0.2.2:3000/api/adoptants');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          animaux = jsonDecode(response.body);
        });
      } else {
        print('Erreur serveur');
      }
    } catch (e) {
      print('Erreur réseau: $e');
    }
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  List<Widget> buildCardsForType(String typeAnimal) {
    final filtered = animaux.where((item) => item['type']?.toLowerCase() == typeAnimal.toLowerCase()).toList();

    if (filtered.isEmpty) {
      return [
        const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text("Aucun animal trouvé pour ce type."),
          ),
        )
      ];
    }

    return filtered.map((item) {
      return Card(
        margin: const EdgeInsets.all(10),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              item['image'] != null
                  ? Image.network(
                'http://10.0.2.2:3000${item['image']}',
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              )
                  : const SizedBox.shrink(),
              const SizedBox(height: 6),
              Text('Type: ${item['type'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 6),
              Text('Sexe: ${item['sex'] ?? ''}'),
              const SizedBox(height: 6),
              Text('Description: ${item['description'] ?? ''}'),
              const SizedBox(height: 6),
              Text('Problème: ${item['probleme'] ?? ''}'),
              const SizedBox(height: 6),
              Text('Publié par: ${item['fullName'] ?? ''}'),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => _launchPhone(item['phone'] ?? ''),
                child: Text(
                  'Téléphone: ${item['phone'] ?? ''}',
                  style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                ),
              ),
              const SizedBox(height: 6),
              Text('Type utilisateur: ${item['userType'] ?? ''}'),
            ],
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Animaux à adopter",style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: mediumBrown,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilterChip(
                label: const Text("Chats🐱"),
                selected: selectedType == "Chat",
                onSelected: (_) => setState(() => selectedType = "Chat"),
                selectedColor: lightPink,
              ),
              const SizedBox(width: 10),
              FilterChip(
                label: const Text("Chiens🐶"),
                selected: selectedType == "Chien",
                onSelected: (_) => setState(() => selectedType = "Chien"),
                selectedColor: lightPink,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: buildCardsForType(selectedType),
            ),
          ),
        ],
      ),
    );
  }
}
