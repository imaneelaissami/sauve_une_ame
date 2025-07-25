import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';


class EditProfileSauveteurPage extends StatefulWidget {
  final String fullName;
  final String profileImage;
  final String phone;
  final String sex;
  final String age;
  final String city;
  final String country;
  final String email;

  const EditProfileSauveteurPage({
    Key? key,
    required this.fullName,
    required this.profileImage,
    required this.phone,
    required this.sex,
    required this.age,
    required this.city,
    required this.country,
    required this.email,
  }) : super(key: key);

  @override
  _EditProfileSauveteurPageState createState() => _EditProfileSauveteurPageState();
}

class _EditProfileSauveteurPageState extends State<EditProfileSauveteurPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController fullNameController;
  late TextEditingController phoneController;
  late TextEditingController ageController;
  late TextEditingController cityController;
  late TextEditingController countryController;

  String sex = 'Homme';

  File? newProfileImage;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fullNameController = TextEditingController(text: widget.fullName);
    phoneController = TextEditingController(text: widget.phone);
    ageController = TextEditingController(text: widget.age.toString());

    cityController = TextEditingController(text: widget.city);
    countryController = TextEditingController(text: widget.country);
    sex = widget.sex;
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        newProfileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final url = Uri.parse('http://10.0.2.2:3000/api/users/update');
    var request = http.MultipartRequest('PUT', url);

    request.fields['email'] = widget.email;
    request.fields['fullName'] = fullNameController.text.trim();
    request.fields['phone'] = phoneController.text.trim();
    request.fields['sex'] = sex;
    request.fields['age'] = ageController.text.trim();
    request.fields['city'] = cityController.text.trim();
    request.fields['country'] = countryController.text.trim();
    // تأكد إذا خاصك userId أو email لل backend عشان يعرف يحدّث البيانات
    // request.fields['email'] = widget.email; مثلا

    if (newProfileImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'profileImage',
        newProfileImage!.path,
      ));
    }

    try {
      var responseStream = await request.send();
      var response = await http.Response.fromStream(responseStream);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          Navigator.pop(context, data['user']);
        } catch (e) {
          print('Erreur dans jsonDecode: $e');
          _showError('Erreur dans la réception des données');
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          _showError(error['message'] ?? 'Erreur inconnue');
        } catch (e) {
          print('Erreur dans jsonDecode (erreur): $e');
          _showError('Erreur inconnue');
        }
      }

    } catch (e) {
      _showError('Erreur réseau: $e');
    }
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Erreur'),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color darkBrown = const Color(0xFF5A1F35);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Modifier votre Profile",
          style: TextStyle(color: Colors.white), // لون النص الأبيض
        ),
        iconTheme: IconThemeData(color: Colors.white), // السهم الأبيض
        backgroundColor: Color(0xFF5A1F35), // لون الخلفية
      ),
      backgroundColor: const Color(0xFFE4CFC8),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: GestureDetector(
                  onTap: pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: newProfileImage != null
                        ? FileImage(newProfileImage!)
                        : (widget.profileImage.isNotEmpty
                        ? NetworkImage('http://10.0.2.2:3000${widget.profileImage}')
                        : const AssetImage('assets/images/profile.jpg')) as ImageProvider,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom complet',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Champ obligatoire' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Champ obligatoire' : null,
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Sexe',
                  border: OutlineInputBorder(),
                ),
                value: sex,
                items: ['Homme', 'Femme']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) => setState(() => sex = val ?? 'Homme'),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Âge',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Champ obligatoire' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: cityController,
                decoration: const InputDecoration(
                  labelText: 'Ville',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Champ obligatoire' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: countryController,
                decoration: const InputDecoration(
                  labelText: 'Pays',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Champ obligatoire' : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkBrown,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  'Enregistrer les modifications',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white, // إضافة اللون الأبيض
                  ),
                ),              ),
            ],
          ),
        ),
      ),
    );
  }
}
