import 'package:flutter/material.dart';
import 'package:et_learn/authentication/auth.dart';
import 'package:et_learn/services/database_service.dart';
import 'package:et_learn/screens/setup_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CourseDetailPage extends StatefulWidget {
  final Map course;

  const CourseDetailPage({super.key, required this.course});

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  final DatabaseService _dbService = DatabaseService();
  final Auth _auth = Auth();
  final supabase = Supabase.instance.client;
  bool sendingRequest = false;

  Future<void> _checkProfileAndRequest() async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to request a course')),
      );
      return;
    }

    // Only require setup when the user has not provided subjects to teach
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

      if (result == true) {
        await _sendRequest();
      }
      return;
    }

    await _sendRequest();
  }

  /// Opens a Date & Time picker for selecting a single preferred slot
  Future<DateTime?> _pickPreferredTime() async {
    // 1. Pick Date
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (date == null) return null;

    if (!mounted) return null;

    // 2. Pick Time
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _sendRequest() async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Ask for preferred schedule
    final scheduledTime = await _pickPreferredTime();
    if (scheduledTime == null) {
      // User cancelled picker
      return;
    }

    setState(() => sendingRequest = true);

    try {
      final courseId = widget.course['id'] as int;
      final mentorUid = widget.course['creator_uid'] as String;

      await _dbService.createCourseRequest(
        courseId: courseId,
        learnerUid: user.uid,
        mentorUid: mentorUid,
        scheduledTime: scheduledTime,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Request sent for ${scheduledTime.toString().split('.')[0]}',
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error sending request: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }

    setState(() => sendingRequest = false);
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;

    // Safely handle teacher info
    final teacher = course['users'] is Map<String, dynamic>
        ? course['users'] as Map<String, dynamic>
        : null;

    final currentUser = _auth.currentUser;
    final bool isOwner = currentUser?.uid == course['creator_uid'];

    return Scaffold(
      appBar: AppBar(title: const Text('Course Details')),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          color: const Color(0xFFF4F8FE),
          child: Column(
            children: [
              // Top banner / thumbnail
              course['thumbnail_url'] != null && course['thumbnail_url'] != ''
                  ? Image.network(
                      course['thumbnail_url'],
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: double.infinity,
                      height: 250,
                      color: Colors.grey.shade300,
                      child: const Center(child: Icon(Icons.image, size: 50)),
                    ),

              // Course info card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course['subject'] ?? 'No Subject',
                      style: const TextStyle(
                        color: Color(0xFFFF6B00),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      course['title'] ?? 'Untitled Course',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          '${course['classes'] ?? 0} Classes',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          '|',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${course['duration_minutes'] ?? 0} Minutes',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${course['credit_cost'] ?? 'Free'} /-',
                      style: const TextStyle(
                        color: Color(0xFF0961F5),
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        Text(
                          'About',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Curriculum',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      course['description'] ?? 'No description',
                      style: const TextStyle(
                        color: Color(0xFFA0A4AB),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              // Instructor section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 27,
                      backgroundImage:
                          teacher != null && teacher['photo_url'] != null
                          ? NetworkImage(teacher['photo_url'])
                          : const AssetImage('assets/avatar_placeholder.png')
                                as ImageProvider,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          teacher?['full_name'] ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          course['subject'] ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF545454),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Request button or owner info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: isOwner
                    ? const Text(
                        'You are the owner of this course',
                        style: TextStyle(color: Colors.grey),
                      )
                    : ElevatedButton(
                        onPressed: sendingRequest
                            ? null
                            : _checkProfileAndRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF167F71),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: sendingRequest
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Request to Learn',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
