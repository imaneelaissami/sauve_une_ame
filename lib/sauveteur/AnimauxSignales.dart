import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// هنا خاصك تكون عندك FilterButton معرّف فملف خارجي أو نفس الملف.
// هاد الكود يقد يكون مثلا:
class FilterButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  const FilterButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        avatar: Icon(icon, color: selected ? Colors.white : color),
        label: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : color,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: selected ? color : Colors.grey[200],
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}

class AnimauxSignales extends StatefulWidget {
  const AnimauxSignales({Key? key}) : super(key: key);

  @override
  State<AnimauxSignales> createState() => _AnimauxSignalesState();
}

class _AnimauxSignalesState extends State<AnimauxSignales> {
  List<dynamic> signalements = [];
  String selectedType = "Chat";

  final Color mediumBrown = const Color(0xFF5A1F35);

  @override
  void initState() {
    super.initState();
    fetchSignalements();
  }

  Future<void> fetchSignalements() async {
    final url = Uri.parse('http://10.0.2.2:3000/api/signal/signalements');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          signalements = data;
        });
      } else {
        print('Erreur de chargement');
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

  Future<void> _launchMap(String address) async {
    final query = Uri.encodeComponent(address);
    final url = Uri.parse("https://www.google.com/maps/search/?api=1&query=$query");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  List<Widget> buildCardsForType(String typeAnimal) {
    final filtered = signalements
        .where((item) => item['typeAnimal']?.toLowerCase() == typeAnimal.toLowerCase())
        .toList();

    if (filtered.isEmpty) {
      return [const Center(child: Padding(
        padding: EdgeInsets.all(20),
        child: Text("Aucun animal signalé."),
      ))];
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
                width: 150, // العرض اللي بغيتي
                height: 150, // الطول اللي بغيتي
                fit: BoxFit.cover, // كيفاش الصورة تتملا فالحجم
              )
                  : const SizedBox.shrink(),
              const SizedBox(height: 6),
              Text(
                'Type: ${item['typeAnimal']}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text('Description: ${item['description'] ?? ''}'),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => _launchMap(item['adresse'] ?? ''),
                child: RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Adresse: ',
                        style: TextStyle(color: Colors.black),
                      ),
                      TextSpan(
                        text: item['adresse'] ?? '',
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => _launchPhone(item['phone'] ?? ''),
                child: RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Téléphone: ',
                        style: TextStyle(color: Colors.black),
                      ),
                      TextSpan(
                        text: item['phone'] ?? '',
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 6),
              Text('Signalé par: ${item['fullName'] ?? ''}'),
              const SizedBox(height: 6),
              Text('Date: ${item['dateSignalement'] ?? ''}'),
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
        title: const Text('Animaux signalés'),
        backgroundColor: mediumBrown,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
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
                },
              ),
              const SizedBox(width: 15),
              FilterButton(
                label: "Chiens",
                icon: Icons.pets,
                color: mediumBrown,
                selected: selectedType == "Chien",
                onTap: () {
                  setState(() {
                    selectedType = "Chien";
                  });
                },
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
