import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'ConseilsPage.dart';
import 'adaptant/MesSignalementsPageA.dart';
import 'adaptant/MesAnimauxAdopterPage.dart';
import 'admin/UserNotificationsPage.dart';
import 'sauveteur/AnimauxSignales.dart';
import 'adaptant/AnimauxAdopterFiltres.dart';

class AdoptantUserPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const AdoptantUserPage({Key? key, required this.userData}) : super(key: key);

  @override
  State<AdoptantUserPage> createState() => _AdoptantUserPageState();
}

class _AdoptantUserPageState extends State<AdoptantUserPage> {
  final Color darkBrown = const Color(0xFF5A1F35);
  Map<String, dynamic> userData = {};


  @override
  void initState() {
    super.initState();
    userData = widget.userData;
    print("AdoptantUserPage UserData: $userData");
  }

  Future<void> _refreshUserData() async {
    final url = Uri.parse('http://10.0.2.2:3000/api/users/getUserByEmail');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': userData['email']}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['user'];
        if (mounted) {
          setState(() {
            userData = {
              'fullName': data['fullName'] ?? '',
              'profileImage': data['profileImage'] ?? '',
              'email': data['email'] ?? '',
              'phone': data['phone'] ?? '',
              'sex': data['sex'] ?? '',
              'age': data['age']?.toString() ?? '',
              'city': data['city'] ?? '',
              'country': data['country'] ?? '',
              'userType': data['userType'] ?? '',
            };
          });
        }
      } else {
        _showInfoDialog(context, 'Erreur', 'Erreur lors de la récupération des données');
      }
    } catch (e) {
      _showInfoDialog(context, 'Erreur', 'Erreur réseau: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE4CFC8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: userData['profileImage'] != ''
                        ? NetworkImage('http://10.0.2.2:3000${userData['profileImage']}')
                        : const AssetImage('assets/images/profile.jpg') as ImageProvider,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Bienvenue', style: TextStyle(color: Colors.black54, fontSize: 14)),
                      Text(
                        userData['fullName'] ?? '',
                        style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  const Spacer(),
                  Image.network(
                    'https://img.icons8.com/?size=100&id=GEAs8ke5mB3W&format=png&color=000000',
                    height: 40,
                    width: 40,
                    color: darkBrown,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _circleIcon(context, Icons.person, () async {
                    final updated = await Navigator.pushNamed(
                      context,
                      '/editProfileAdoptant',
                      arguments: userData,
                    );

                    if (updated != null && mounted) {
                      if (updated is Map<String, dynamic>) {
                        setState(() {
                          userData = Map<String, dynamic>.from(updated);
                        });
                      } else {
                        print('Erreur: updated n\'est pas un Map<String, dynamic>');
                      }
                    }
                  }),
                  _circleIcon(context, Icons.info_outline, () {
                    Navigator.pushNamed(context, '/conditions');
                  }),


                  _circleIcon(context, Icons.lightbulb, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ConseilsPage()),
                    );
                  }),
                  IconButton(
                    icon: Icon(Icons.notifications),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserNotificationsPage(email: userData['email']),
                        ),
                      );
                    },
                  ),

                  IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: _refreshUserData,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _mainButtonCustom(context, Icons.pets, 'Tous les animaux à adopter ', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AnimauxAdopterFiltres()),
                      );
                    }),
                    const SizedBox(height: 40),
                    _mainButtonCustom(context, Icons.warning_amber_rounded, 'Tous les animaux signalés', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AnimauxSignales()),
                      );
                    }),
                    const SizedBox(height: 40),
                    _mainButtonCustom(context, Icons.home, 'Proposer mes animaux à l’adoption', () {
                      Navigator.pushNamed(
                        context,
                        '/publierAnimal',
                        arguments: {
                          'fullName': userData['fullName'],
                          'email': userData['email'],
                          'phone': userData['phone'],
                          'userType': userData['userType'],
                        },
                      );
                    }),



                    const SizedBox(height: 40),
                    _mainButtonCustom(context, Icons.report, 'Signaler un animal', () {
                      Navigator.pushNamed(context, '/signalerAnimal', arguments: userData);
                    }),

                    const SizedBox(height: 40),
                    // Mes signalements
                    _mainButtonCustom(context, Icons.list_alt, 'Mes signalements', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MesSignalementsPageA(email: userData['email']),
                        ),
                      );
                    }),
                    const SizedBox(height: 40),
                    _mainButtonCustom(context, Icons.pets, 'Mes animaux à adopter', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>MesAnimauxAdopterPage(userData: userData),

                        ),
                      );
                    }),




                    const Spacer(),
                    GestureDetector(
                      onTap: () => _confirmLogout(context),
                      child: const Text(
                        'Se déconnecter',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontSize: 22,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2)),
                ],
              ),
              child: const Center(
                child: Text(
                  'Page Adoptant',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mainButtonCustom(BuildContext context, IconData icon, String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white, size: 20),
        label: Text(label, style: const TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5A1F35),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onPressed,
      ),
    );
  }


  Widget _circleIcon(BuildContext context, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        backgroundColor: darkBrown,
        radius: 23,
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer')),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
