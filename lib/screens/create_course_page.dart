import 'dart:typed_data';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:et_learn/services/user_sync_service.dart';
import 'package:et_learn/screens/setup_profile.dart';

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

  File? thumbnail; // Mobile
  Uint8List? thumbnailBytes; // Web

  final supabase = Supabase.instance.client;
  final user = FirebaseAuth.instance.currentUser!;

  List<String> subjectsTeach = [];

  int get creditCost {
    final minutes = int.tryParse(durationCtrl.text.trim()) ?? 0;
    return (minutes / 2).ceil(); // 1 credit = 2 minutes
  }

  @override
  void initState() {
    super.initState();
    _checkProfileAndLoad();
    durationCtrl.addListener(() => setState(() {})); // live update credit cost
  }

  Future<void> _checkProfileAndLoad() async {
    // Only trigger setup when the user has not provided subjects to teach
    final profile = await supabase
        .from('users')
        .select('subjects_teach')
        .eq('uid', user.uid)
        .maybeSingle();

    final needsSubjectSetup =
        profile == null || profile['subjects_teach'] == null;

    if (needsSubjectSetup) {
      if (!mounted) return;
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SetupProfilePage()),
      );

      // If the user bails out of setup, leave the page
      if (result != true) {
        if (mounted) Navigator.pop(context);
        return;
      }
    }

    // Load subjects after ensuring the profile has teaching subjects
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
        if (subjectsTeach.isNotEmpty) {
          selectedSubject = subjectsTeach.first;
        }
      });
    }
  }

  Future<void> _pickThumbnail() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked != null) {
      if (kIsWeb) {
        thumbnailBytes = await picked.readAsBytes();
      } else {
        thumbnail = File(picked.path);
      }
      setState(() {});
    }
  }

  Future<String?> _uploadThumbnail() async {
    if (thumbnail == null && thumbnailBytes == null) return null;

    final path =
        'images/${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';

    try {
      if (kIsWeb && thumbnailBytes != null) {
        // Upload for web
        await supabase.storage
            .from('images')
            .uploadBinary(
              path,
              thumbnailBytes!,
              fileOptions: const FileOptions(upsert: true),
            );
      } else if (thumbnail != null) {
        // Upload for mobile
        await supabase.storage
            .from('images')
            .upload(
              path,
              thumbnail!,
              fileOptions: const FileOptions(upsert: true),
            );
      }

      // Get public URL
      final publicUrl = supabase.storage.from('images').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      if (!mounted) return null;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Image upload failed: $e")));
      return null;
    }
  }

  Future<void> _createCourse() async {
    if (!_formKey.currentState!.validate() || selectedSubject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final thumbUrl = await _uploadThumbnail();
    final now = DateTime.now().toUtc().toIso8601String();

    await supabase.from('courses').insert({
      'creator_uid': user.uid,
      'title': titleCtrl.text.trim(),
      'subject': selectedSubject,
      'description': descCtrl.text.trim(),
      'thumbnail_url': thumbUrl, // ✅ Works now
      'duration_minutes': int.parse(durationCtrl.text),
      'credit_cost': creditCost, // auto-calculated
      'level': level,
      'created_at': now,
      'updated_at': now,
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Course created successfully!')),
    );

    Navigator.pop(context, true);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = thumbnail != null || thumbnailBytes != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FE),
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _pickThumbnail,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 58,
                              backgroundColor: Colors.white,
                              backgroundImage: hasImage
                                  ? (kIsWeb
                                        ? MemoryImage(thumbnailBytes!)
                                        : FileImage(thumbnail!)
                                              as ImageProvider)
                                  : null,
                              child: !hasImage
                                  ? const Icon(
                                      Icons.add_photo_alternate_outlined,
                                      size: 42,
                                      color: Colors.grey,
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Tap to add course thumbnail',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      _inputCard(titleCtrl, 'Course Title'),
                      _inputCard(descCtrl, 'Description', maxLines: 3),
                      _dropdownCard(
                        'Subject',
                        subjectsTeach,
                        selectedSubject,
                        (v) => setState(() => selectedSubject = v),
                      ),
                      _inputCard(
                        durationCtrl,
                        'Duration (minutes)',
                        keyboard: TextInputType.number,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16, left: 4),
                          child: Text(
                            'Credit Cost: $creditCost credit(s)',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0961F5),
                            ),
                          ),
                        ),
                      ),
                      _dropdownCard(
                        'Level',
                        const ['Beginner', 'Intermediate', 'Advanced'],
                        level,
                        (v) => setState(() => level = v!),
                      ),
                      const SizedBox(height: 36),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _createCourse,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0961F5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Create Course',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: const [
          BackButton(),
          Text(
            'Create Course',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Color(0xFF202244),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputCard(
    TextEditingController ctrl,
    String label, {
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: _cardDecoration(),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboard,
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
        decoration: InputDecoration(border: InputBorder.none, labelText: label),
      ),
    );
  }

  Widget _dropdownCard(
    String label,
    List<String> options,
    String? value,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: _cardDecoration(),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        items: options
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(border: InputBorder.none, labelText: label),
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: const [
      BoxShadow(color: Color(0x19000000), blurRadius: 8, offset: Offset(0, 2)),
    ],
  );
}
