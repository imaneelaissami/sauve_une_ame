import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';



class EditProfileNormalUserPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfileNormalUserPage({Key? key, required this.userData}) : super(key: key);

  @override
  _EditProfileNormalUserPageState createState() => _EditProfileNormalUserPageState();
}

class _EditProfileNormalUserPageState extends State<EditProfileNormalUserPage> {
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
    fullNameController = TextEditingController(text: widget.userData['fullName']);
    phoneController = TextEditingController(text: widget.userData['phone']);
    ageController = TextEditingController(text: widget.userData['age'].toString());
    cityController = TextEditingController(text: widget.userData['city']);
    countryController = TextEditingController(text: widget.userData['country']);
    sex = widget.userData['sex'];
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => newProfileImage = File(pickedFile.path));
    }
  }

  Future<void> saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final url = Uri.parse('http://10.0.2.2:3000/api/users/update');
    var request = http.MultipartRequest('PUT', url);

    request.fields['email'] = widget.userData['email'];
    request.fields['fullName'] = fullNameController.text.trim();
    request.fields['phone'] = phoneController.text.trim();
    request.fields['sex'] = sex;
    request.fields['age'] = ageController.text.trim();
    request.fields['city'] = cityController.text.trim();
    request.fields['country'] = countryController.text.trim();

    if (newProfileImage != null) {
      request.files.add(await http.MultipartFile.fromPath('profileImage', newProfileImage!.path));
    }

    try {
      var responseStream = await request.send();
      var response = await http.Response.fromStream(responseStream);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Navigator.pop(context, data['user']);
      } else {
        final error = jsonDecode(response.body);
        _showError(error['message'] ?? 'Erreur inconnue');
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
    const Color darkBrown = Color(0xFF5A1F35);

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
                        : (widget.userData['profileImage'].toString().isNotEmpty
                        ? NetworkImage('http://10.0.2.2:3000${widget.userData['profileImage']}')
                        : const AssetImage('assets/images/profile.jpg')) as ImageProvider,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildField('Nom complet', fullNameController),
              _buildField('Téléphone', phoneController, type: TextInputType.phone),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Sexe',
                  border: OutlineInputBorder(),
                ),
                value: sex,
                items: ['Homme', 'Femme'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => sex = val ?? 'Homme'),
              ),
              const SizedBox(height: 15),
              _buildField('Âge', ageController, type: TextInputType.number),
              _buildField('Ville', cityController),
              _buildField('Pays', countryController),
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
                ),                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (v) => (v == null || v.isEmpty) ? 'Champ obligatoire' : null,
      ),
    );
  }
}
