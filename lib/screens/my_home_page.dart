import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:et_learn/screens/profile_view.dart';
import 'package:et_learn/screens/my_courses_view.dart';
import 'package:et_learn/screens/search_page.dart';
import 'package:et_learn/screens/inbox_screen.dart';
import 'package:et_learn/widgets/mentor_widgets.dart';
import 'package:et_learn/widgets/base_scaffold.dart';
import 'package:et_learn/authentication/auth.dart';
import 'package:et_learn/helpers/credits.dart';
import 'package:et_learn/screens/course_detail_page.dart';
import 'package:et_learn/screens/create_course_page.dart';
import 'package:et_learn/screens/all_courses_page.dart';
import 'package:et_learn/screens/all_mentors_page.dart';
import 'package:et_learn/screens/mentor_profile_page.dart';
import 'package:et_learn/services/database_service.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final supabase = Supabase.instance.client;
  final user = Auth().currentUser;
  final DatabaseService _dbService = DatabaseService();

  int _currentIndex = 0;
  bool loadingCourses = true;
  bool loadingMentors = true;
  List<Map<String, dynamic>> featuredCourses = [];
  List<Map<String, dynamic>> featuredMentors = [];

  @override
  void initState() {
    super.initState();
    _loadFeaturedContent();
  }

  Future<void> _loadFeaturedContent() async {
    await Future.wait([_fetchFeaturedCourses(), _fetchFeaturedMentors()]);
  }

  Future<void> _fetchFeaturedCourses() async {
    try {
      if (user == null) {
        setState(() => loadingCourses = false);
        return;
      }

      final courses = await _dbService.getFeaturedCourses(
        currentUserUid: user!.uid,
        limit: 6,
      );

      setState(() {
        featuredCourses = courses;
        loadingCourses = false;
      });
    } catch (e) {
      debugPrint('Error fetching featured courses: $e');
      setState(() => loadingCourses = false);
    }
  }

  Future<void> _fetchFeaturedMentors() async {
    try {
      final mentors = await _dbService.getAllMentors();
      debugPrint('Fetched mentors: $mentors');
      setState(() {
        featuredMentors = mentors.take(3).toList(); // take top 2 for homepage
        loadingMentors = false;
      });
    } catch (e) {
      debugPrint('Error fetching featured mentors: $e');
      setState(() => loadingMentors = false);
    }
  }

  Widget _homeContent() {
    return RefreshIndicator(
      onRefresh: _loadFeaturedContent,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _header(),
          _pad(_searchBar(), top: 20),
          // Featured Courses Section
          _pad(
            _sectionTitle(
              "Featured Courses",
              onSeeMore: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AllCoursesPage()),
                );
              },
            ),
            top: 30,
          ),
          _pad(
            loadingCourses
                ? const Center(child: CircularProgressIndicator())
                : featuredCourses.isEmpty
                ? const Center(child: Text('No courses available'))
                : Column(
                    children: featuredCourses.take(3).map((course) {
                      // Safely get the teacher map
                      final teacher = (course['users'] is Map<String, dynamic>)
                          ? course['users'] as Map<String, dynamic>
                          : null;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CourseDetailPage(course: course),
                            ),
                          );
                        },
                        child: CourseCard(
                          title: course['title']?.toString() ?? 'Untitled',
                          subject: course['subject']?.toString() ?? '',
                          level: course['level']?.toString() ?? 'Beginner',
                          duration: course['duration_minutes'] ?? 0,
                          thumbnail: course['thumbnail_url']?.toString(),
                          teacherName:
                              teacher?['full_name']?.toString() ?? 'Unknown',
                          courseId: course['id'],
                          teacherUid: course['creator_uid']?.toString(),
                          supabase: supabase,
                          currentUserUid: user?.uid,
                        ),
                      );
                    }).toList(),
                  ),
            top: 20,
          ),
          // Featured Mentors Section
          _pad(
            _sectionTitle(
              "Featured Mentors",
              onSeeMore: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AllMentorsPage()),
                );
              },
            ),
            top: 30,
          ),
          _pad(_featuredMentors(), top: 15),
          // Extra space so the floating action button does not cover the last item
          const SizedBox(height: 90),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateCoursePage()),
          );
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Create Course",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF167F71),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF167F71),
        unselectedItemColor: const Color(0xFF202244),
        selectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
          fontFamily: 'Mulish',
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
          fontFamily: 'Mulish',
        ),
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: 'MY COURSES',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inbox_outlined),
            activeIcon: Icon(Icons.inbox),
            label: 'INBOX',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'PROFILE',
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _homeContent(),
            const MyCoursesView(),
            const InboxScreen(),
            const Padding(padding: EdgeInsets.all(20.0), child: ProfileView()),
          ],
        ),
      ),
    );
  }

  // ---------------- Helper Widgets ----------------

  Widget _pad(Widget child, {double top = 0}) {
    return Padding(
      padding: EdgeInsets.only(top: top),
      child: child,
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ValueListenableBuilder<int>(
                valueListenable: totalCreditsNotifier,
                builder: (context, totalCredits, _) {
                  return Text(
                    "Hi, ${user?.displayName ?? 'User'}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF202244),
                    ),
                  );
                },
              ),
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  "What would you like to learn today?",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF545454),
                  ),
                ),
              ),
            ],
          ),
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Color(0xFF167F71), width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SearchPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                "Search for...",
                style: TextStyle(
                  color: Color(0xFFB4BDC4),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF0961F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.search, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, {VoidCallback? onSeeMore}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF202244),
            ),
          ),
          GestureDetector(
            onTap: onSeeMore,
            child: const Text(
              "SEE MORE",
              style: TextStyle(
                color: Color(0xFF0961F5),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _featuredMentors() {
    if (loadingMentors) {
      return const Center(child: CircularProgressIndicator());
    }

    if (featuredMentors.isEmpty) {
      return const Center(child: Text('No mentors available'));
    }

    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          const SizedBox(width: 4),
          ...featuredMentors.take(2).map((mentor) {
            // <-- only take top 2
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          MentorProfilePage(mentorUid: mentor['uid']),
                    ),
                  );
                },
                child: MentorTile(
                  name: mentor['full_name'] ?? 'Unknown',
                  subtitle:
                      (mentor['subjects_teach'] as List?)?.isNotEmpty == true
                      ? (mentor['subjects_teach'] as List).first.toString()
                      : 'Mentor',
                  photoUrl: mentor['photo_url']?.toString(),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ---------------- Course Card ----------------
class CourseCard extends StatelessWidget {
  final String title;
  final String subject;
  final String level;
  final int duration;
  final String? thumbnail;
  final String teacherName;
  final int courseId; // Needed to reference course
  final String? teacherUid; // UID of the course creator
  final SupabaseClient supabase;
  final String? currentUserUid;

  const CourseCard({
    super.key,
    required this.title,
    required this.subject,
    required this.level,
    required this.duration,
    required this.thumbnail,
    required this.teacherName,
    required this.courseId,
    required this.teacherUid,
    required this.supabase,
    required this.currentUserUid,
  });

  Future<void> requestToLearn(BuildContext context) async {
    if (currentUserUid == null || teacherUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in or teacher unknown')),
      );
      return;
    }

    try {
      // Insert request into 'offers' table
      await supabase.from('offers').insert({
        'uid': currentUserUid,
        'type': 'learn',
        'subject': subject,
        'description': 'Request to learn "$title"',
        'status': 'open',
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Request sent to teacher!')));
    } catch (e) {
      debugPrint('Error sending learn request: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to send request')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
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
                    child: const Center(child: Icon(Icons.image, size: 48)),
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
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => requestToLearn(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF167F71),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Request to Learn',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
