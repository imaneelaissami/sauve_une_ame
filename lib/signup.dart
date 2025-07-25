import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  String fullName = '';
  String email = '';
  String sex = 'Homme';
  String age = '';
  String city = '';
  String country = '';
  String phone = '';
  String password = '';
  String userType = 'normalUser';
  File? profileImage;

  final List<Map<String, String>> userTypes = [
    {'value': 'normalUser', 'label': 'Normal'},
    {'value': 'adoptantUser', 'label': 'Adoptant'},
    {'value': 'sauveteurUser', 'label': 'Sauveteur'},
  ];

  final Color lightPink = const Color(0xFFE4CFC8);
  final Color mediumBrown = const Color(0xFFB57D7F);
  final Color darkBrown = const Color(0xFF5A1F35);

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> registerUser() async {
    final url = Uri.parse('http://10.0.2.2:3000/api/users/register');

    try {
      var request = http.MultipartRequest('POST', url);

      request.fields['fullName'] = fullName;
      email = email.trim();
      request.fields['email'] = email;
      request.fields['sex'] = sex;
      request.fields['age'] = age;
      request.fields['city'] = city;
      request.fields['country'] = country;
      request.fields['phone'] = phone;
      request.fields['password'] = password;
      request.fields['userType'] = userType;

      // في حالة الصورة موجودة فقط نضيفها
      if (profileImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profileImage',
          profileImage!.path,
        ));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // userType ممكن يكون جاي من الـ backend أو من الاختيار المحلي
        final registeredUserType = data['user']?['userType'] ?? userType;
        final registeredFullName = data['user']?['fullName'] ?? fullName;

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Succès'),
            content: Text('✅ Compte créé avec succès pour $registeredFullName'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  final user = data['user'];
                  final args = {
                    'fullName': user['fullName']?.toString() ?? '',
                    'email': user['email']?.toString() ?? '',
                    'phone': user['phone']?.toString() ?? '',
                    'sex': user['sex']?.toString() ?? '',
                    'age': user['age']?.toString() ?? '', // خليه int بلا toString
                    'city': user['city']?.toString() ?? '',
                    'country': user['country']?.toString() ?? '',
                    'userType': user['userType']?.toString() ?? '',
                    'profileImageUrl': user['profileImage']?.toString() ?? '',
                    'password': '', // الباسورد ديما نخلوه فارغ
                  };

                  if (registeredUserType == "sauveteurUser") {
                    Navigator.pushReplacementNamed(context, '/sauveteurUser', arguments: args);
                  } else if (registeredUserType == "adoptantUser") {
                    Navigator.pushReplacementNamed(context, '/adoptantUser', arguments: args);
                  } else if (registeredUserType == "superadmin") {
                    Navigator.pushReplacementNamed(context, '/superadmin', arguments: args);
                  } else {
                    Navigator.pushReplacementNamed(context, '/normalUser', arguments: args);
                  }
                },
                child: Text('OK'),
              )
            ],
          ),
        );
      } else {
        final error = jsonDecode(response.body);
        _showError(error['details'] ?? error['message'] ?? 'Erreur inconnue');
      }
    } catch (e) {
      _showError('Erreur de connexion : $e');
    }
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Erreur'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightPink,
      appBar: AppBar(
        backgroundColor: darkBrown,
        foregroundColor: Colors.white,
        title: Text('Créer un compte'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: profileImage != null
                        ? FileImage(profileImage!) as ImageProvider
                        : const NetworkImage(
                        'https://cdn-icons-png.flaticon.com/512/149/149071.png'),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nom complet *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                (value == null || value.isEmpty) ? 'Champ obligatoire' : null,
                onSaved: (value) => fullName = value ?? '',
              ),
              const SizedBox(height: 15),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Champ obligatoire';
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!emailRegex.hasMatch(value)) return 'Email invalide';
                  return null;
                },
                onSaved: (value) => email = value ?? '',
              ),

              const SizedBox(height: 15),

              // Sexe
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Sexe *',
                  border: OutlineInputBorder(),
                ),
                value: sex,
                items: ['Homme', 'Femme']
                    .map((sex) => DropdownMenuItem(
                  value: sex,
                  child: Text(sex),
                ))
                    .toList(),
                onChanged: (val) => setState(() => sex = val ?? 'Homme'),
              ),

              const SizedBox(height: 15),

// Âge
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Âge *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                (value == null || value.isEmpty) ? 'Champ obligatoire' : null,
                onSaved: (value) => age = value ?? '',
              ),

              const SizedBox(height: 15),

// Pays
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Pays *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                (value == null || value.isEmpty) ? 'Champ obligatoire' : null,
                onSaved: (value) => country = value ?? '',
              ),

              const SizedBox(height: 15),
              // Ville
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Ville *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                (value == null || value.isEmpty) ? 'Champ obligatoire' : null,
                onSaved: (value) => city = value ?? '',
              ),

              const SizedBox(height: 15),


              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Téléphone *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                (value == null || value.isEmpty) ? 'Champ obligatoire' : null,
                onSaved: (value) => phone = value ?? '',
              ),
              const SizedBox(height: 15),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Mot de passe *',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Champ obligatoire';
                  if (value.length < 6) return 'Au moins 6 caractères';
                  return null;
                },
                onSaved: (value) => password = value ?? '',
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Type d\'utilisateur *',
                  border: OutlineInputBorder(),
                ),
                value: userType,
                items: userTypes
                    .map((type) => DropdownMenuItem(
                  value: type['value'],
                  child: Text(type['label']!),
                ))
                    .toList(),
                onChanged: (val) => setState(() => userType = val ?? 'normalUser'),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkBrown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    registerUser();
                  }
                },
                child: const Text('Créer un compte'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
