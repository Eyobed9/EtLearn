import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:et_learn/widget_tree.dart';

class SetupProfilePage extends StatefulWidget {
  const SetupProfilePage({super.key});

  @override
  State<SetupProfilePage> createState() => _SetupProfilePageState();
}

class _SetupProfilePageState extends State<SetupProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final fullNameCtrl = TextEditingController();
  final professionCtrl = TextEditingController();
  final teachCtrl = TextEditingController();
  final bioCtrl = TextEditingController();

  DateTime? dob;
  String gender = 'Male';
  File? imageFile;

  final supabase = Supabase.instance.client;
  final user = FirebaseAuth.instance.currentUser!;

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => imageFile = File(picked.path));
    }
  }

  Future<String?> uploadImage() async {
    if (imageFile == null) return null;

    final path = 'avatars/${user.uid}.jpg';

    await supabase.storage
        .from('avatars')
        .upload(path, imageFile!, fileOptions: const FileOptions(upsert: true));

    return supabase.storage.from('avatars').getPublicUrl(path);
  }

  Future<void> saveProfile() async {
    if (!_formKey.currentState!.validate() || dob == null) return;

    final imageUrl = await uploadImage();

    await supabase.from('users').upsert({
      'uid': user.uid,
      'email': user.email,
      'full_name': fullNameCtrl.text.trim(),
      'photo_url': imageUrl,
      'gender': gender,
      'date_of_birth': dob!.toIso8601String(),
      'profession': professionCtrl.text.trim(),
      'bio': bioCtrl.text.trim(),
      'subjects_teach': teachCtrl.text.split(',').map((e) => e.trim()).toList(),
      'last_active': DateTime.now().toIso8601String(),
    });

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile setup completed')));
      // After successful setup, send user to the app home.
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WidgetTree()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FE),
      appBar: AppBar(title: const Text('Setup Profile'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  backgroundImage: imageFile != null
                      ? FileImage(imageFile!)
                      : null,
                  child: imageFile == null
                      ? const Icon(Icons.camera_alt, size: 28)
                      : null,
                ),
              ),
              const SizedBox(height: 20),

              _input(fullNameCtrl, 'Full Name'),
              _readonlyField(user.email ?? '', 'Email'),
              _datePicker(),
              _genderPicker(),
              _input(professionCtrl, 'Profession'),
              _input(teachCtrl, 'Subjects to Teach (comma separated)'),
              _input(bioCtrl, 'Short Bio', maxLines: 3),

              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: saveProfile,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Complete Setup'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(TextEditingController c, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: c,
        maxLines: maxLines,
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
        decoration: _decoration(label),
      ),
    );
  }

  Widget _readonlyField(String value, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: value,
        enabled: false,
        decoration: _decoration(label),
      ),
    );
  }

  Widget _datePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          dob == null
              ? 'Date of Birth'
              : dob!.toLocal().toString().split(' ')[0],
        ),
        trailing: const Icon(Icons.calendar_today),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            firstDate: DateTime(1950),
            lastDate: DateTime.now(),
            initialDate: DateTime(2000),
          );
          if (picked != null) setState(() => dob = picked);
        },
      ),
    );
  }

  Widget _genderPicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: gender,
        items: [
          'Male',
          'Female',
          'Other',
        ].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
        onChanged: (v) => setState(() => gender = v!),
        decoration: _decoration('Gender'),
      ),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
