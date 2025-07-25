import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class PublierAnimalAdoptionPage extends StatefulWidget {
  final Map<String, dynamic> user; // fullName, email, phone, userType

  const PublierAnimalAdoptionPage({super.key, required this.user});

  @override
  State<PublierAnimalAdoptionPage> createState() => _PublierAnimalAdoptionPageState();
}

class _PublierAnimalAdoptionPageState extends State<PublierAnimalAdoptionPage> {
  final _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();

  File? _image;
  String? _type; // chat ou chien
  String? _sex;
  String? _description;
  String? _probleme;

  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _image == null || _type == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs obligatoires.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    var uri = Uri.parse('http://10.0.2.2:3000/api/adoptants/create');
    var request = http.MultipartRequest('POST', uri);

    request.fields['type'] = _type!;
    request.fields['sex'] = _sex!;
    request.fields['description'] = _description!;
    request.fields['probleme'] = _probleme ?? '';
    request.fields['fullName'] = widget.user['fullName'];
    request.fields['email'] = widget.user['email'];
    request.fields['phone'] = widget.user['phone'];
    request.fields['userType'] = widget.user['userType'];

    final mimeType = lookupMimeType(_image!.path)?.split('/');
    if (mimeType != null && mimeType.length == 2) {
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        _image!.path,
        contentType: MediaType(mimeType[0], mimeType[1]),
      ));
    }

    final response = await request.send();
    final resBody = await response.stream.bytesToString();
    print('Status Code: ${response.statusCode}');
    print('Response Body: $resBody');

    setState(() => _isLoading = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Animal publié avec succès!')),
      );
      Navigator.pop(context); // revenir à la page précédente
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Échec de l'enregistrement.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Publier un animal à adopter ',
          style: TextStyle(color: Colors.white), // ← النص باللون الأبيض
        ),
        backgroundColor: const Color(0xFF5A1F35),
        iconTheme: const IconThemeData(color: Colors.white), // ← السهم باللون الأبيض
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: _image == null
                      ? const Icon(Icons.add_a_photo, size: 50)
                      : Image.file(_image!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Type d\'animal'),
                items: const [
                  DropdownMenuItem(value: 'Chien', child: Text('Chien')),
                  DropdownMenuItem(value: 'Chat', child: Text('Chat')),
                ],
                onChanged: (value) => _type = value,
                validator: (value) => value == null ? 'Veuillez choisir un type' : null,
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Sexe de l\'animal'),
                items: const [
                  DropdownMenuItem(value: 'Mâle', child: Text('Mâle')),
                  DropdownMenuItem(value: 'Femelle', child: Text('Femelle')),
                ],
                onChanged: (value) => setState(() => _sex = value),
                validator: (value) => value == null ? 'Veuillez choisir un sexe' : null,
              ),

              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                onChanged: (value) => _description = value,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Maladie ou handicap (facultatif)',
                ),
                onChanged: (value) => _probleme = value,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.check, color: Colors.white),  // الأيقونة باللون الأبيض
                label: const Text(
                  'Publier',
                  style: TextStyle(color: Colors.white),  // النص باللون الأبيض
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A1F35),
                ),
                onPressed: _submitForm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
