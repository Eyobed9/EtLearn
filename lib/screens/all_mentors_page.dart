import 'package:flutter/material.dart';
import 'package:et_learn/services/database_service.dart';
import 'package:et_learn/screens/mentor_profile_page.dart';

class AllMentorsPage extends StatefulWidget {
  const AllMentorsPage({super.key});

  @override
  State<AllMentorsPage> createState() => _AllMentorsPageState();
}

class _AllMentorsPageState extends State<AllMentorsPage> {
  final DatabaseService _dbService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _mentors = [];
  List<Map<String, dynamic>> _filteredMentors = [];
  bool _loading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadMentors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMentors() async {
    setState(() => _loading = true);
    try {
      // Fetch mentors: users with subjects_teach not empty
      final mentors = await _dbService.getMentors();
      setState(() {
        _mentors = mentors;
        _filteredMentors = mentors;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading mentors: $e');
      setState(() => _loading = false);
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredMentors = _mentors;
      } else {
        _filteredMentors = _mentors.where((mentor) {
          final name = (mentor['full_name'] ?? '').toString().toLowerCase();
          final bio = (mentor['bio'] ?? '').toString().toLowerCase();
          final queryLower = query.toLowerCase();
          return name.contains(queryLower) || bio.contains(queryLower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FE),
      appBar: AppBar(
        title: const Text(
          'All Mentors',
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
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Container(
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
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: const InputDecoration(
                  hintText: 'Search mentors...',
                  prefixIcon: Icon(Icons.search, color: Color(0xFF0961F5)),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                ),
              ),
            ),
          ),
          // Mentors list
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredMentors.isEmpty
                    ? Center(
                        child: Text(
                          _searchQuery.isEmpty
                              ? 'No mentors available'
                              : 'No mentors found',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadMentors,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _filteredMentors.length,
                          itemBuilder: (context, index) {
                            final mentor = _filteredMentors[index];
                            return _MentorListItem(
                              mentor: mentor,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MentorProfilePage(
                                        mentorUid: mentor['uid']),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _MentorListItem extends StatelessWidget {
  final Map<String, dynamic> mentor;
  final VoidCallback onTap;

  const _MentorListItem({
    required this.mentor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final subjects = mentor['subjects_teach'] ?? [];
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Profile picture
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: mentor['photo_url'] != null &&
                        mentor['photo_url'] != ''
                    ? NetworkImage(mentor['photo_url'])
                    : null,
                child: mentor['photo_url'] == null || mentor['photo_url'] == ''
                    ? const Icon(Icons.person, size: 30)
                    : null,
              ),
              const SizedBox(width: 16),
              // Mentor info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mentor['full_name'] ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (mentor['bio'] != null &&
                        mentor['bio'].toString().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        mentor['bio'],
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (subjects.isNotEmpty)
                          ...subjects
                              .take(2)
                              .map((s) => Padding(
                                    padding:
                                        const EdgeInsets.only(right: 4.0),
                                    child: Chip(
                                      label: Text(s.toString()),
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ))
                              .toList(),
                        const Spacer(),
                        Text(
                          '${mentor['credits'] ?? 0} credits',
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
  }
}
