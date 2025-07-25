import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'ConseilsPage.dart';
import 'sauveteur/MesAnimauxAdopterPage.dart';
import 'admin/UserNotificationsPage.dart';
import 'sauveteur/AnimauxSignales.dart';


class SauveteurUserPage extends StatefulWidget {

  final String fullName;
  final String profileImage;
  final String email;
  final String phone;
  final String sex;
  final String age;
  final String city;
  final String country;
  final String userType;

  const SauveteurUserPage({
    Key? key,
    required this.fullName,
    required this.profileImage,
    required this.email,
    required this.phone,
    required this.sex,
    required this.age,
    required this.city,
    required this.country,
    required this.userType,
  }) : super(key: key);

  @override
  State<SauveteurUserPage> createState() => _SauveteurUserPageState();
}

class _SauveteurUserPageState extends State<SauveteurUserPage> {


  final Color darkBrown = const Color(0xFF5A1F35);
  late Map<String, dynamic> user;

  @override
  void initState() {
    super.initState();
    user = {
      'fullName': widget.fullName,
      'profileImage': widget.profileImage,
      'email': widget.email,
      'phone': widget.phone,
      'sex': widget.sex,
      'age': widget.age,
      'city': widget.city,
      'country': widget.country,
      'userType': widget.userType,
    };
  }

  Future<void> _refreshUserData() async {
    final url = Uri.parse('http://10.0.2.2:3000/api/users/getUserByEmail');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': widget.email}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['user'];
        if (mounted) {
          setState(() {
            user = {
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
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: user['profileImage'].isNotEmpty
                        ? NetworkImage('http://10.0.2.2:3000${user['profileImage']}')
                        : const AssetImage('assets/images/profile.jpg') as ImageProvider,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Bienvennu', style: TextStyle(color: Colors.black87, fontSize: 18)),
                      Text(
                        user['fullName'],
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
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
            const SizedBox(height: 20),

            // Icons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _circleIcon(context, Icons.person, () async {
                    final updatedUser = await Navigator.pushNamed(
                      context,
                      '/editProfileSauveteur',
                      arguments: user,
                    );

                    if (updatedUser != null && mounted) {
                      setState(() {
                        user = updatedUser as Map<String, dynamic>;
                      });
                    }
                  }),
                  _circleIcon(context, Icons.lightbulb, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ConseilsPage()),
                    );
                  }),
                  _circleIcon(context, Icons.info_outline, () {
                    Navigator.pushNamed(context, '/conditions');
                  }),
                  IconButton(
                    icon: Icon(Icons.notifications),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserNotificationsPage(email: user['email']),
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

            // Main buttons
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _mainButton(context, Icons.warning_amber_rounded, 'Sauvé un animal', () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AnimauxSignales()),
                      );
                    }),

                    const SizedBox(height: 40),
                    _mainButton(context, Icons.upload, 'Publier un animal pour adopter', () {
                      Navigator.pushNamed(context, '/publierAnimal', arguments: user);
                    }),

                    const SizedBox(height: 40),

                    _mainButton(context, Icons.list_alt, 'Mes animaux à adopter', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MesAnimauxAdopterPage(userData: user), // دوز الـ Map كامل
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
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Page Sauveteur',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mainButton(BuildContext context, IconData icon, String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: darkBrown,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onPressed,  // استعمل الدالة مباشرة
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
