import 'package:flutter/material.dart';
import 'package:et_learn/authentication/auth.dart';
import 'package:et_learn/authentication/login_page.dart';
import 'package:et_learn/services/database_service.dart';
import 'package:et_learn/helpers/credits.dart';
import 'package:et_learn/screens/setup_profile.dart';
import 'package:et_learn/screens/course_detail_page.dart';
import 'package:jitsi_meet_wrapper/jitsi_meet_wrapper.dart';
import 'package:et_learn/widget_tree.dart'; // For converting time formatting if needed, or just standard parsing

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final DatabaseService _dbService = DatabaseService();
  final Auth _auth = Auth();

  Map<String, dynamic>? _userProfile;
  List<Map<String, dynamic>> _teachingCourses = [];
  List<Map<String, dynamic>> _learningCourses = [];
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Load user profile from database
      final profile = await _dbService.getUserProfile(user.uid);

      // Load courses
      final teaching = await _dbService.getCoursesByCreator(user.uid);
      final learning = await _dbService.getEnrolledCourses(user.uid);
      final notifications = await _dbService.getMeetingInvites(user.uid);

      // Update credits notifier
      if (profile != null) {
        totalCreditsNotifier.value = profile['credits'] ?? 0;
      }

      setState(() {
        _userProfile = profile;
        _teachingCourses = teaching;
        _learningCourses = learning.map((e) {
          final course = e['courses'] as Map<String, dynamic>?;
          return course ?? <String, dynamic>{};
        }).toList();
        _notifications = notifications;
      });
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return RefreshIndicator(
      onRefresh: _loadProfile,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Header
            _buildProfileHeader(user),
            const SizedBox(height: 24),
            // Validations for Meeting
            if (_notifications.isNotEmpty) ...[
              _buildNotificationsSection(),
              const SizedBox(height: 24),
            ],
            // Credits Balance
            _buildCreditsCard(),
            const SizedBox(height: 24),
            // Bio Section
            if (_userProfile?['bio'] != null &&
                _userProfile!['bio'].toString().isNotEmpty)
              _buildBioSection(),
            // Skills/Interests Section
            if (_userProfile?['skills'] != null ||
                _userProfile?['subjects_teach'] != null)
              _buildSkillsSection(),
            const SizedBox(height: 24),
            // Courses Teaching
            if (_teachingCourses.isNotEmpty)
              _buildCoursesSection('Teaching', _teachingCourses),
            // Courses Learning
            if (_learningCourses.isNotEmpty)
              _buildCoursesSection('Learning', _learningCourses),
            const SizedBox(height: 24),
            // Settings Card
            _buildSettingsCard(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(user) {
    final photoUrl = _userProfile?['photo_url']?.toString() ?? user?.photoURL;
    final fullName =
        _userProfile?['full_name']?.toString() ?? user?.displayName ?? 'User';
    final email =
        _userProfile?['email']?.toString() ?? user?.email ?? 'No email';

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            photoUrl != null && photoUrl.isNotEmpty
                ? Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(photoUrl),
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(
                        color: const Color(0xFF167F71),
                        width: 4,
                      ),
                    ),
                  )
                : Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade300,
                      border: Border.all(
                        color: const Color(0xFF167F71),
                        width: 4,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          fontSize: 36,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
            GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SetupProfilePage()),
                );
                if (result == true) {
                  _loadProfile();
                }
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF167F71), width: 3),
                ),
                child: const Icon(Icons.edit, size: 18),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          fullName,
          style: const TextStyle(
            fontSize: 24,
            fontFamily: 'Jost',
            fontWeight: FontWeight.w600,
            color: Color(0xFF202244),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: const TextStyle(
            fontSize: 13,
            fontFamily: 'Mulish',
            fontWeight: FontWeight.w700,
            color: Color(0xFF545454),
          ),
        ),
      ],
    );
  }

  Widget _buildCreditsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
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
      child: ValueListenableBuilder<int>(
        valueListenable: totalCreditsNotifier,
        builder: (context, credits, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Icon(
                    Icons.account_balance_wallet,
                    color: Color(0xFF0961F5),
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$credits',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0961F5),
                    ),
                  ),
                  const Text(
                    'Credits',
                    style: TextStyle(fontSize: 12, color: Color(0xFF545454)),
                  ),
                ],
              ),
              Container(width: 1, height: 50, color: Colors.grey.shade300),
              Column(
                children: [
                  const Icon(Icons.school, color: Color(0xFF167F71), size: 32),
                  const SizedBox(height: 8),
                  Text(
                    '${_teachingCourses.length}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF167F71),
                    ),
                  ),
                  const Text(
                    'Teaching',
                    style: TextStyle(fontSize: 12, color: Color(0xFF545454)),
                  ),
                ],
              ),
              Container(width: 1, height: 50, color: Colors.grey.shade300),
              Column(
                children: [
                  const Icon(Icons.book, color: Color(0xFFFF6B00), size: 32),
                  const SizedBox(height: 8),
                  Text(
                    '${_learningCourses.length}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6B00),
                    ),
                  ),
                  const Text(
                    'Learning',
                    style: TextStyle(fontSize: 12, color: Color(0xFF545454)),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBioSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
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
            'Bio',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            _userProfile!['bio'],
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
    final subjects = _userProfile?['subjects_teach'] as List<dynamic>? ?? [];
    final skills = _userProfile?['skills'] as List<dynamic>? ?? [];

    if (subjects.isEmpty && skills.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  Widget _buildCoursesSection(
    String title,
    List<Map<String, dynamic>> courses,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
            'Courses $title (${courses.length})',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...courses.take(3).map((course) {
            return ListTile(
              leading:
                  course['thumbnail_url'] != null &&
                      course['thumbnail_url'].toString().isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        course['thumbnail_url'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.book),
                    ),
              title: Text(course['title'] ?? 'Untitled'),
              subtitle: Text(course['subject'] ?? ''),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CourseDetailPage(course: course),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 8),
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
        children: [
          _profileItem(
            Icons.person,
            'Edit Profile',
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SetupProfilePage()),
              );
              if (result == true) {
                _loadProfile();
              }
            },
          ),
          _profileItem(Icons.notifications, 'Notifications'),
          _profileItem(Icons.security, 'Security'),
          _profileItem(Icons.help_center, 'Help Center'),
          _profileItem(
            Icons.logout,
            'Logout',
            color: Colors.red,
            onTap: () async {
              await _auth.signOut();
              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _profileItem(
    IconData icon,
    String title, {
    Widget? trailing,
    Color color = const Color(0xFF202244),
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Mulish',
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildNotificationsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0961F5).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.video_call, color: Color(0xFF0961F5)),
              SizedBox(width: 8),
              Text(
                'Active Sessions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF202244),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._notifications.map((msg) {
            final content = msg['content'] as String;
            final match = RegExp(r'Pass: (\S+)').firstMatch(content);
            final password = match?.group(1) ?? '';

            final sender = msg['users'] as Map<String, dynamic>?;
            final senderName = sender?['full_name'] ?? 'Mentor';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$senderName started a session',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  if (password.isNotEmpty)
                    SelectableText(
                      'Password: $password',
                      style: TextStyle(color: Colors.grey[700], fontSize: 13),
                    ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0961F5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => _joinMeeting(content),
                      child: const Text('Join Class'),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _joinMeeting(String content) async {
    final regExp = RegExp(r'Join: (https://meet.jit.si/(\S+)) Pass: (\S+)');
    final match = regExp.firstMatch(content);

    if (match != null) {
      final roomName = match.group(2);
      final password = match.group(3);

      if (roomName != null) {
        var options = JitsiMeetingOptions(
          roomNameOrUrl: roomName,
          userDisplayName:
              _userProfile?['full_name'] ??
              _auth.currentUser?.displayName ??
              'Learner',
          userEmail: _auth.currentUser?.email,
          userAvatarUrl:
              _userProfile?['photo_url'] ?? _auth.currentUser?.photoURL,
          configOverrides: {
            "startWithAudioMuted": true,
            "startWithVideoMuted": true,
            if (password != null) "roomPassword": password,
          },
        );

        try {
          await JitsiMeetWrapper.joinMeeting(options: options);
        } catch (error) {
          debugPrint("Jitsi Error: $error");
          // Only show error, don't crash app
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error joining meeting: $error")),
            );
          }
        }
      }
    } else {
      // Fallback for older messages format if needed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid meeting link format")),
      );
    }
  }
}
