import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final Color darkBrown = const Color(0xFF5A1F35);
  bool isLoading = false;

  Future<void> _login() async {
    final url = Uri.parse('http://10.0.2.2:3000/api/users/login');

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text,
          'password': passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('==> DATA FROM SERVER: $data');

        print('Login response data: $data');



        // نفترض API كترجع هاد البيانات
        final user = data['user'];



        String userType = user['userType'] ?? 'normalUser';
        String fullName = user['fullName'] ?? 'Utilisateur';
        String profileImage = user['profileImage'] ?? '';
        String email = user['email'] ?? '';
        String phone = user['phone'] ?? '';
        String sex = user['sex'] ?? '';
        String age = user['age']?.toString() ?? '';
        String city = user['city'] ?? '';
        String country = user['country'] ?? '';
        String password = user['password'] ?? '';


        // بناء على نوع المستخدم، ندخلوه لصفحتو الخاصة
        String route = '/normalUser'; // default

        if (userType == 'sauveteurUser') {
          route = '/sauveteurUser';
        } else if (userType == 'adoptantUser') {
          route = '/adoptantUser';
        } else if (userType == 'superadmin') {
          route = '/superadmin';
        }

        // تنقل للصفحة المناسبة مع إرسال البيانات كـ arguments
        Navigator.pushReplacementNamed(
          context,
          route,

          arguments: {
            'fullName': fullName,
            'profileImage': profileImage,
            'email': email,
            'phone': phone,
            'sex': sex,
            'age': age,
            'city': city,
            'country': country,
            'userType': userType,
            'password': password,

          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur réseau: $e')),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkBrown,
        foregroundColor: Colors.white,
        title: Text('Se connecter'),
      ),
      backgroundColor: const Color(0xFFE4CFC8),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const SizedBox(height: 30),
            Image.network(
              'https://img.icons8.com/?size=100&id=GEAs8ke5mB3W&format=png&color=000000',
              color: darkBrown,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 10),
            const Text(
              'Sauver un animal, c’est cultiver la bonté en soi 💗',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontStyle: FontStyle.italic,
                color: Colors.black,
                fontWeight: FontWeight.w500,
               // fontFamily: 'Georgia',
              ),
            ),
            const SizedBox(height: 40), // مسافة بين الشعار والفورم

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Mot de passe',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 30),
            isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkBrown,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _login,
                child: const Text('Se connecter', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
