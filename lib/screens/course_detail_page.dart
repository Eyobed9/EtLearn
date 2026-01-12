import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CourseDetailPage extends StatefulWidget {
  final Map course;

  const CourseDetailPage({super.key, required this.course});

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  final supabase = Supabase.instance.client;
  bool sendingRequest = false;

  Future<void> sendRequest() async {
    setState(() => sendingRequest = true);

    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      await supabase.from('offers').insert({
        'uid': user.id,
        'type': 'learn',
        'subject': widget.course['subject'],
        'description':
            'Request to learn "${widget.course['title']}"',
        'status': 'open',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request sent successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

    setState(() => sendingRequest = false);
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    final teacher = course['users'];
    final currentUser = supabase.auth.currentUser;

    final bool isOwner = currentUser?.id == course['creator_uid'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            course['thumbnail_url'] != null
                ? Image.network(
                    course['thumbnail_url'],
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 220,
                    color: Colors.grey.shade300,
                    child: const Center(child: Icon(Icons.image, size: 50)),
                  ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course['title'],
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    'By ${teacher?['full_name'] ?? 'Unknown'}',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Chip(label: Text(course['subject'])),
                      const SizedBox(width: 8),
                      Chip(label: Text(course['level'])),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Text('⏱ Duration: ${course['duration_minutes']} minutes'),

                  const SizedBox(height: 20),
                  const Text(
                    'Description',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(course['description'] ?? 'No description'),

                  const SizedBox(height: 30),

                  if (!isOwner)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: sendingRequest ? null : sendRequest,
                        child: sendingRequest
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('Request Session'),
                      ),
                    ),

                  if (isOwner)
                    const Text(
                      'You are the owner of this course',
                      style: TextStyle(color: Colors.grey),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
