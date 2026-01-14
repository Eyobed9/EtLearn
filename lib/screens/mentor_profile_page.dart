import 'package:flutter/material.dart';
import 'package:et_learn/services/database_service.dart';
import 'package:et_learn/screens/course_detail_page.dart';

class MentorProfilePage extends StatefulWidget {
  final String mentorUid;

  const MentorProfilePage({super.key, required this.mentorUid});

  @override
  State<MentorProfilePage> createState() => _MentorProfilePageState();
}

class _MentorProfilePageState extends State<MentorProfilePage> {
  final DatabaseService _dbService = DatabaseService();
  Map<String, dynamic>? _mentor;
  List<Map<String, dynamic>> _courses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMentorProfile();
  }

  Future<void> _loadMentorProfile() async {
    setState(() => _loading = true);
    try {
      final mentor = await _dbService.getMentorProfile(widget.mentorUid);
      final courses = await _dbService.getCoursesByCreator(widget.mentorUid);
      
      setState(() {
        _mentor = mentor;
        _courses = courses;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading mentor profile: $e');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FE),
      appBar: AppBar(
        title: const Text(
          'Mentor Profile',
          style: TextStyle(
            color: Color(0xFF202244),
            fontFamily: 'Jost',
            fontSize: 21,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _mentor == null
              ? const Center(child: Text('Mentor not found'))
              : RefreshIndicator(
                  onRefresh: _loadMentorProfile,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Header
                        _buildProfileHeader(),
                        const SizedBox(height: 24),
                        // Bio Section
                        if (_mentor!['bio'] != null && _mentor!['bio'].toString().isNotEmpty)
                          _buildBioSection(),
                        // Skills/Subjects Section
                        if (_mentor!['subjects_teach'] != null ||
                            _mentor!['skills'] != null)
                          _buildSkillsSection(),
                        const SizedBox(height: 24),
                        // Courses Section
                        _buildCoursesSection(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
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
      child: Row(
        children: [
          // Profile Picture
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: _mentor!['photo_url'] != null &&
                    _mentor!['photo_url'].toString().isNotEmpty
                ? NetworkImage(_mentor!['photo_url'])
                : null,
            child: _mentor!['photo_url'] == null ||
                    _mentor!['photo_url'].toString().isEmpty
                ? const Icon(Icons.person, size: 40)
                : null,
          ),
          const SizedBox(width: 16),
          // Name and Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _mentor!['full_name'] ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _mentor!['email'] ?? '',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.stars, color: Color(0xFF0961F5), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${_mentor!['credits'] ?? 0} credits',
                      style: const TextStyle(
                        color: Color(0xFF0961F5),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBioSection() {
    return Container(
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
          const Text(
            'About',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _mentor!['bio'],
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection() {
    final subjects = _mentor!['subjects_teach'] as List<dynamic>? ?? [];
    final skills = _mentor!['skills'] as List<dynamic>? ?? [];

    if (subjects.isEmpty && skills.isEmpty) return const SizedBox.shrink();

    return Container(
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
          if (subjects.isNotEmpty) ...[
            const Text(
              'Subjects Teaching',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: subjects.map((subject) {
                return Chip(
                  label: Text(subject.toString()),
                  backgroundColor: const Color(0xFFE8F1FF),
                );
              }).toList(),
            ),
            if (skills.isNotEmpty) const SizedBox(height: 20),
          ],
          if (skills.isNotEmpty) ...[
            const Text(
              'Skills & Interests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills.map((skill) {
                return Chip(
                  label: Text(skill.toString()),
                  backgroundColor: const Color(0xFFE8F1FF),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCoursesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Courses (${_courses.length})',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _courses.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    'No courses available',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _courses.length,
                itemBuilder: (context, index) {
                  final course = _courses[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () {
                        // Need to fetch full course details with creator info
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CourseDetailPage(course: course),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Thumbnail
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: course['thumbnail_url'] != null &&
                                      course['thumbnail_url'].toString().isNotEmpty
                                  ? Image.network(
                                      course['thumbnail_url'],
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey.shade300,
                                      child: const Icon(Icons.image, size: 32),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            // Course Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    course['title'] ?? 'Untitled',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    course['subject'] ?? '',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Chip(
                                        label: Text(course['level'] ?? 'Beginner'),
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      const Spacer(),
                                      Text(
                                        '${course['credit_cost'] ?? 0} credits',
                                        style: const TextStyle(
                                          color: Color(0xFF0961F5),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }
}
