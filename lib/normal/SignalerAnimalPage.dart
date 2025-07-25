import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // لإلتقاط الصور
import 'package:location/location.dart'; // لجلب الإحداثيات
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignalerAnimalPage extends StatefulWidget {
  final Map<String, dynamic> currentUser;

  const SignalerAnimalPage({Key? key, required this.currentUser}) : super(key: key);

  @override
  _SignalerAnimalPageState createState() => _SignalerAnimalPageState();
}

class _SignalerAnimalPageState extends State<SignalerAnimalPage> {
  final _formKey = GlobalKey<FormState>();

  File? _imageFile;
  final picker = ImagePicker();

  String? _typeAnimal; // 'Chien' or 'Chat'
  String _description = '';
  String _phone = '';

  double? _latitude;
  double? _longitude;

  bool _isSubmitting = false;

  // إضافة TextEditingController لحقل العنوان
  final TextEditingController _adresseController = TextEditingController();

  @override
  void dispose() {
    _adresseController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _getLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        _showMessage('Service de localisation désactivé');
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        _showMessage('Permission de localisation refusée');
        return;
      }
    }

    LocationData locationData = await location.getLocation();

    setState(() {
      _latitude = locationData.latitude;
      _longitude = locationData.longitude;

      // ملء حقل العنوان بالإحداثيات (يمكن تعديلها يدوياً من طرف المستخدم)
      _adresseController.text = 'Latitude: ${_latitude!.toStringAsFixed(5)}, Longitude: ${_longitude!.toStringAsFixed(5)}';
    });

    _showMessage('Position récupérée et ajoutée dans l\'adresse');
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imageFile == null) {
      _showMessage('Veuillez sélectionner une image.');
      return;
    }

    if ((_latitude == null || _longitude == null) && _adresseController.text.trim().isEmpty) {
      _showMessage('Veuillez entrer une adresse ou utiliser la localisation.');
      return;
    }


    setState(() {
      _isSubmitting = true;
    });

    _formKey.currentState!.save();

    try {
      var uri = Uri.parse('http://10.0.2.2:3000/api/signal/signalAnimal'); // عدلها حسب الـ backend

      var request = http.MultipartRequest('POST', uri);

      // إضافة الصورة
      request.files.add(await http.MultipartFile.fromPath('image', _imageFile!.path));

      // إضافة باقي البيانات في body
      request.fields['typeAnimal'] = _typeAnimal!;
      request.fields['description'] = _description;
      request.fields['adresse'] = _adresseController.text.trim();
      request.fields['phone'] = _phone;

      request.fields['latitude'] = _latitude.toString();
      request.fields['longitude'] = _longitude.toString();

      // معلومات المستخدم تلقائية
      request.fields['fullName'] = widget.currentUser['fullName'] ?? '';
      request.fields['email'] = widget.currentUser['email'] ?? '';
      request.fields['userType'] = widget.currentUser['userType'] ?? '';

      var response = await request.send();

      if (response.statusCode == 200) {
        _showMessage('Animal signalé avec succès.');
        Navigator.pop(context, true); // ترجع true عند النجاح
      } else {
        _showMessage('Erreur lors de la soumission. Code: ${response.statusCode}');
      }
    } catch (e) {
      _showMessage('Erreur réseau: $e');
    }

    setState(() {
      _isSubmitting = false;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Signaler un animal ',
          style: TextStyle(color: Colors.white), // ← النص باللون الأبيض
        ),
        backgroundColor: const Color(0xFF5A1F35),
        iconTheme: const IconThemeData(color: Colors.white), // ← السهم باللون الأبيض
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // صورة الحيوان مصغرة شوي
              GestureDetector(
                onTap: _pickImage,
                child: _imageFile == null
                    ? Container(
                  height: 140,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                )
                    : Image.file(_imageFile!, height: 140, fit: BoxFit.cover),
              ),
              const SizedBox(height: 20),

              // نوع الحيوان (Dropdown)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Type d\'animal',
                  border: OutlineInputBorder(),
                ),
                value: _typeAnimal,
                items: ['Chien', 'Chat'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setState(() => _typeAnimal = val),
                validator: (val) => val == null || val.isEmpty ? 'Veuillez choisir un type' : null,
              ),
              const SizedBox(height: 20),

              // Description
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onSaved: (val) => _description = val?.trim() ?? '',
                validator: (val) => val == null || val.trim().isEmpty ? 'Veuillez entrer une description' : null,
              ),
              const SizedBox(height: 20),

              // Adresse مع controller
              TextFormField(
                controller: _adresseController,
                decoration: const InputDecoration(
                  labelText: 'Adresse',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.edit),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Veuillez entrer une adresse' : null,
              ),
              const SizedBox(height: 10),

              // زر "Localiser moi"
              ElevatedButton.icon(
                onPressed: _getLocation,
                icon: const Icon(Icons.my_location, color: Colors.white),  // الأيقونة باللون الأبيض
                label: const Text(
                  'Localiser moi',
                  style: TextStyle(color: Colors.white),  // النص باللون الأبيض
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A1F35),
                ),
              ),


              const SizedBox(height: 20),

              // عرض الإحداثيات نص فقط (اختياري)
              if (_latitude != null && _longitude != null)
                Text('Latitude: $_latitude, Longitude: $_longitude'),

              const SizedBox(height: 20),

              // رقم الهاتف
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Numéro de téléphone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                onSaved: (val) => _phone = val?.trim() ?? '',
                validator: (val) => val == null || val.trim().isEmpty ? 'Veuillez entrer un numéro' : null,
              ),

              const SizedBox(height: 30),

              _isSubmitting
                  ? const CircularProgressIndicator()
                  : SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Signaler', style: TextStyle(color: Colors.white,fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5A1F35),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
