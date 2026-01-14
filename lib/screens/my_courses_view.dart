import 'package:flutter/material.dart';
import 'package:et_learn/authentication/auth.dart';
import 'package:et_learn/services/database_service.dart';
import 'package:et_learn/screens/course_detail_page.dart';

enum CourseTabType { learning, teaching }

class MyCoursesView extends StatefulWidget {
  const MyCoursesView({super.key});

  @override
  State<MyCoursesView> createState() => _MyCoursesViewState();
}

class _MyCoursesViewState extends State<MyCoursesView> {
  final DatabaseService _dbService = DatabaseService();
  final Auth _auth = Auth();

  CourseTabType selectedTab = CourseTabType.learning;

  List<Map<String, dynamic>> learningCourses = [];
  List<Map<String, dynamic>> teachingCourses = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    setState(() => loading = true);

    final user = _auth.currentUser;
    if (user == null) {
      setState(() => loading = false);
      return;
    }

    try {
      // 1️⃣ Fetch courses the user is learning (via enrollments)
      final enrolledCourses = await _dbService.getEnrolledCourses(user.uid);
      learningCourses = enrolledCourses.map((e) {
        final course = e['courses'] as Map<String, dynamic>?;
        if (course == null) return <String, dynamic>{};
        return {
          ...course,
          'progress': ((e['progress_percentage'] ?? 0) as int) / 100.0,
        };
      }).toList();

      // 2️⃣ Fetch courses the user is teaching (creator_uid)
      teachingCourses = await _dbService.getCoursesByCreator(user.uid);
    } catch (e) {
      debugPrint('Error fetching courses: $e');
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        children: [
          const Padding(padding: EdgeInsets.only(top: 8)),
          const Padding(
            padding: EdgeInsets.only(top: 8.0, bottom: 12.0),
            child: Text(
              'My Courses',
              style: TextStyle(
                color: Color(0xFF202244),
                fontFamily: 'Jost',
                fontWeight: FontWeight.w600,
                fontSize: 21,
              ),
            ),
          ),
          _searchBox(),
          const Padding(padding: EdgeInsets.only(top: 20)),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    selectedTab = CourseTabType.learning;
                  }),
                  child: _CourseTab(
                    title: 'Learning',
                    selected: selectedTab == CourseTabType.learning,
                  ),
                ),
              ),
              const Padding(padding: EdgeInsets.only(left: 12)),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    selectedTab = CourseTabType.teaching;
                  }),
                  child: _CourseTab(
                    title: 'Teaching',
                    selected: selectedTab == CourseTabType.teaching,
                  ),
                ),
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.only(top: 20)),
          if (loading)
            const Center(child: CircularProgressIndicator())
          else if (selectedTab == CourseTabType.learning)
            learningCourses.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'No courses you\'re learning yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : Column(
                    children: learningCourses.map((course) => GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CourseDetailPage(course: course),
                              ),
                            );
                          },
                          child: CourseCard(
                            category: course['subject'] ?? 'Unknown',
                            title: course['title'] ?? '',
                            rating: '⭐',
                            duration:
                                '${(course['duration_minutes'] ?? 0) ~/ 60} Hrs ${(course['duration_minutes'] ?? 0) % 60} Mins',
                            progress: course['progress'] ?? 0.0,
                            progressText:
                                '${((course['progress'] ?? 0.0) * 100).toInt()}%',
                            progressColor: const Color(0xFF167F71),
                          ),
                        )).toList(),
                  )
          else
            teachingCourses.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'No courses you\'re teaching yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : Column(
                    children: teachingCourses.map((course) => GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CourseDetailPage(course: course),
                              ),
                            );
                          },
                          child: CourseCard(
                            category: course['subject'] ?? 'Unknown',
                            title: course['title'] ?? '',
                            rating: '⭐',
                            duration:
                                '${(course['duration_minutes'] ?? 0) ~/ 60} Hrs ${(course['duration_minutes'] ?? 0) % 60} Mins',
                            progress: 0.0,
                            progressText: '0%',
                            progressColor: const Color(0xFFFCCB40),
                          ),
                        )).toList(),
                  ),
        ],
      ),
    );
  }

  Widget _searchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Search for …',
              style: TextStyle(
                color: Color(0xFFB4BDC4),
                fontFamily: 'Mulish',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF0961F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.search, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// ---------------- Course Card ----------------
class CourseCard extends StatelessWidget {
  final String category;
  final String title;
  final String rating;
  final String duration;
  final double progress;
  final String progressText;
  final Color progressColor;

  const CourseCard({
    required this.category,
    required this.title,
    required this.rating,
    required this.duration,
    required this.progress,
    required this.progressText,
    required this.progressColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category,
              style: const TextStyle(
                color: Color(0xFFFF6B00),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 8),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Color(0xFFFFD166)),
                    const Padding(padding: EdgeInsets.only(left: 6)),
                    Text(
                      rating,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const Padding(padding: EdgeInsets.only(left: 12)),
                    const Text('|', style: TextStyle(fontSize: 14)),
                    const Padding(padding: EdgeInsets.only(left: 12)),
                    Text(
                      duration,
                      style: const TextStyle(color: Color(0xFF545454)),
                    ),
                  ],
                ),
                Text(
                  progressText,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.only(top: 8)),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                color: progressColor,
                backgroundColor: Colors.grey.shade200,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Tab Widget ----------------
class _CourseTab extends StatelessWidget {
  final String title;
  final bool selected;

  const _CourseTab({required this.title, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        boxShadow: selected
            ? const [BoxShadow(color: Color(0x14000000), blurRadius: 8)]
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        title,
        style: TextStyle(
          color: selected ? const Color(0xFF202244) : const Color(0xFFB4BDC4),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
