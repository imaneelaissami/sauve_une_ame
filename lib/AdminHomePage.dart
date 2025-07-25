import 'package:flutter/material.dart';
import 'admin/NormalUsersAdminPage.dart';
import 'admin/SauveteurUsersAdminPage.dart';
import 'admin/AdaptantUsersAdminPage.dart';
import 'admin/AdoptedAnimalsPage.dart';
import 'admin/AnimauxSignalesAdminPage.dart';
import 'admin/ConditionsAdminPage.dart';
import 'admin/AdminConseilsPage.dart';

class AdminHomePage extends StatelessWidget {
  final Map<String, dynamic>? arguments;

  // ألوان ثابتة
  final Color lightPink = const Color(0xFFE4CFC8);
  final Color mediumBrown = const Color(0xFFB57D7F);
  final Color darkBrown = const Color(0xFF5A1F35);

  AdminHomePage({Key? key, this.arguments}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('Arguments reçus: $arguments');
    final String fullName = arguments?['fullName'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin 👑 $fullName',style: TextStyle(color: Colors.white, fontSize: 26)),
        backgroundColor: darkBrown,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        color: lightPink,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          children: [
            // شعار التطبيق
            Container(
              height: 100,
              child: Image.network(
                'https://img.icons8.com/3d-fluency/94/cat.png',
                color: darkBrown,
                fit: BoxFit.contain,
                width: 200,
                height: 200,
              ),
            ),
            const SizedBox(height: 20),

            // شبكة الأزرار الدائرية (3 في الصف)
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [

                  // الصف الثاني (3 أزرار)
                  buildCircleButton('Utilisateur Normal', Icons.person_outline, mediumBrown, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NormalUsersAdminPage()),
                    );
                  }),
                  buildCircleButton('Utilisateur Sauveteur', Icons.volunteer_activism, mediumBrown, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SauveteurUsersAdminPage()),
                    );
                  }),
                  buildCircleButton('Utilisateur Adoptant', Icons.favorite_outline, mediumBrown, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AdaptantUsersAdminPage()),
                    );
                  }),
                  // الصف الثالث (2 أزرار + خانة فارغة)
                  buildCircleButton('Animaux Adoptants', Icons.pets, mediumBrown, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AdoptedAnimalsPage()),
                    );
                  }),
                  buildCircleButton('Animaux Signalés', Icons.report, mediumBrown, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AnimauxSignalesAdminPage()),
                    );
                  }),
                  SizedBox(), // خانة فارغة
                  buildCircleButton('Règlements', Icons.rule, mediumBrown, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ConditionsAdminPage()),
                    );
                  }),
                  buildCircleButton('Conseils', Icons.lightbulb, mediumBrown, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AdminConseilsPage()),
                    );
                  }),
                  SizedBox(),
                ],
              ),
            ),

            // زر Déconnecter في الأسفل مع تأكيد الخروج
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: TextButton(
                onPressed: () async {
                  bool? confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirmer la déconnexion'),
                      content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Annuler'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Oui'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
                child: Text(
                  'Déconnecter',
                  style: TextStyle(
                    color: darkBrown,
                    fontSize: 18,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة لبناء زر دائري
  Widget buildCircleButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: CircleAvatar(
            radius: 30,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: 30),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, color: darkBrown),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
