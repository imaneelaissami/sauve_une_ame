import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditProfileAdoptantPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfileAdoptantPage({Key? key, required this.userData}) : super(key: key);

  @override
  _EditProfileAdoptantPageState createState() => _EditProfileAdoptantPageState();
}

class _EditProfileAdoptantPageState extends State<EditProfileAdoptantPage> {
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _ageController;
  // حذفنا _sexController
  late TextEditingController _cityController;
  late TextEditingController _countryController;

  String sex = 'Homme';  // متغير للاختيار بدل controller

  File? _imageFile;
  final _formKey = GlobalKey<FormState>();
  final Color darkBrown = const Color(0xFF5A1F35);

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.userData['fullName']);
    _phoneController = TextEditingController(text: widget.userData['phone']);
    _ageController = TextEditingController(text: widget.userData['age'].toString());
    sex = widget.userData['sex'] ?? 'Homme'; // تعيين القيمة المبدئية لـ sex
    _cityController = TextEditingController(text: widget.userData['city']);
    _countryController = TextEditingController(text: widget.userData['country']);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final uri = Uri.parse('http://10.0.2.2:3000/api/users/update');
    var request = http.MultipartRequest('PUT', uri);

    request.fields['email'] = widget.userData['email'];  // مهم جداً
    request.fields['fullName'] = _fullNameController.text;
    request.fields['phone'] = _phoneController.text;
    request.fields['sex'] = sex; // استعملنا المتغير بدل controller
    request.fields['age'] = _ageController.text;
    request.fields['city'] = _cityController.text;
    request.fields['country'] = _countryController.text;

    if (_imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('profileImage', _imageFile!.path));
    }

    final response = await request.send();
    final respStr = await response.stream.bytesToString();

    print('Status: ${response.statusCode}');
    print('Response Body: $respStr');

    if (response.statusCode == 200) {
      final responseData = jsonDecode(respStr)['user'];
      Navigator.pop(context, responseData);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${response.statusCode}')),
      );
    }
  }

  Widget _buildSexDropdown() {
    return DropdownButtonFormField<String>(
      value: sex,
      decoration: InputDecoration(
        labelText: 'Sexe',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      items: ['Homme', 'Femme']
          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
          .toList(),
      onChanged: (val) {
        if (val != null) {
          setState(() {
            sex = val;
          });
        }
      },
      validator: (value) => value == null || value.isEmpty ? 'Ce champ est requis' : null,
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) => value == null || value.isEmpty ? 'Ce champ est requis' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE4CFC8),
      appBar: AppBar(
        backgroundColor: darkBrown,
        title: const Text('Modifier mon profil', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : NetworkImage('http://10.0.2.2:3000${widget.userData['profileImage']}') as ImageProvider,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(_fullNameController, 'Nom complet'),
              _buildTextField(_phoneController, 'Téléphone'),
              _buildTextField(_ageController, 'Âge'),
              _buildSexDropdown(),  // هنا Dropdown بدل TextField الخاص بالsex
              _buildTextField(_cityController, 'Ville'),
              _buildTextField(_countryController, 'Pays'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkBrown,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
