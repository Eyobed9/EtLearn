import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateCoursePage extends StatefulWidget {
  const CreateCoursePage({super.key});

  @override
  State<CreateCoursePage> createState() => _CreateCoursePageState();
}

class _CreateCoursePageState extends State<CreateCoursePage> {
  final _formKey = GlobalKey<FormState>();

  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final durationCtrl = TextEditingController();

  String? selectedSubject;
  String level = 'Beginner';
  File? thumbnail;

  final supabase = Supabase.instance.client;
  final user = FirebaseAuth.instance.currentUser!;

  List<String> subjectsTeach = [];

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    final res = await supabase
        .from('users')
        .select('subjects_teach')
        .eq('uid', user.uid)
        .maybeSingle();

    if (res != null && res['subjects_teach'] != null) {
      setState(() {
        subjectsTeach = List<String>.from(res['subjects_teach']);
        if (subjectsTeach.isNotEmpty) selectedSubject = subjectsTeach.first;
      });
    }
  }

  Future<void> _pickThumbnail() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        thumbnail = File(picked.path);
      });
    }
  }

  Future<String?> _uploadThumbnail() async {
    if (thumbnail == null) return null;

    final path =
        'course_thumbnails/${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';

    await supabase.storage
        .from('courses')
        .upload(path, thumbnail!, fileOptions: const FileOptions(upsert: true));

    return supabase.storage.from('courses').getPublicUrl(path);
  }

  Future<void> _createCourse() async {
    if (!_formKey.currentState!.validate() || selectedSubject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final thumbUrl = await _uploadThumbnail();

    try {
      await supabase.from('courses').insert({
        'creator_uid': user.uid,
        'title': titleCtrl.text.trim(),
        'subject': selectedSubject,
        'description': descCtrl.text.trim(),
        'thumbnail_url': thumbUrl,
        'duration_minutes': int.tryParse(durationCtrl.text.trim()),
        'level': level,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course created successfully!')),
      );

      Navigator.pop(context); // Go back to previous page
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error creating course: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Course')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickThumbnail,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: thumbnail != null
                      ? FileImage(thumbnail!)
                      : null,
                  child: thumbnail == null
                      ? const Icon(Icons.image, size: 30)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              _inputField(titleCtrl, 'Course Title'),
              _inputField(descCtrl, 'Description', maxLines: 3),
              _dropdownField(
                'Subject',
                subjectsTeach,
                selectedSubject,
                (v) => setState(() => selectedSubject = v),
              ),
              _inputField(
                durationCtrl,
                'Duration (minutes)',
                keyboard: TextInputType.number,
              ),
              _dropdownField(
                'Level',
                ['Beginner', 'Intermediate', 'Advanced'],
                level,
                (v) {
                  if (v != null) setState(() => level = v);
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createCourse,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Create Course'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(
    TextEditingController ctrl,
    String label, {
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboard,
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _dropdownField(
    String label,
    List<String> options,
    String? value,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        items: options
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      ),
    );
  }
}
