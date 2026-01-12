import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'course_detail_page.dart'; // ✅ make sure this path is correct

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final supabase = Supabase.instance.client;

  bool loading = true;
  List courses = [];

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    try {
      final response = await supabase.from('courses').select('''
        id,
        title,
        subject,
        description,
        thumbnail_url,
        duration_minutes,
        level,
        creator_uid,
        created_at,
        users (
          full_name,
          photo_url
        )
      ''').order('created_at', ascending: false);

      setState(() {
        courses = response;
        loading = false;
      });
    } catch (e) {
      debugPrint('Error fetching courses: $e');
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : courses.isEmpty
              ? const Center(child: Text('No courses available'))
              : RefreshIndicator(
                  onRefresh: fetchCourses,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      final teacher = course['users'];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CourseDetailPage(course: course),
                            ),
                          );
                        },
                        child: CourseCard(
                          title: course['title'],
                          subject: course['subject'],
                          level: course['level'],
                          duration: course['duration_minutes'],
                          thumbnail: course['thumbnail_url'],
                          teacherName:
                              teacher?['full_name'] ?? 'Unknown',
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create-course');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  final String title;
  final String subject;
  final String level;
  final int duration;
  final String? thumbnail;
  final String teacherName;

  const CourseCard({
    super.key,
    required this.title,
    required this.subject,
    required this.level,
    required this.duration,
    required this.thumbnail,
    required this.teacherName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12)),
            child: thumbnail != null && thumbnail!.isNotEmpty
                ? Image.network(
                    thumbnail!,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 160,
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(Icons.image, size: 48),
                    ),
                  ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'By $teacherName',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Chip(label: Text(subject)),
                    const SizedBox(width: 8),
                    Chip(label: Text(level)),
                  ],
                ),

                const SizedBox(height: 8),
                Text('⏱ $duration minutes'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
