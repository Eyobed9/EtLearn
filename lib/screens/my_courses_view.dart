import 'package:flutter/material.dart';

class MyCoursesView extends StatelessWidget {
  const MyCoursesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        children: [
          const SizedBox(height: 8),

          // Title (replaces AppBar title when embedded)
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

          // Search box
          _searchBox(),

          const SizedBox(height: 20),

          // Tabs
          Row(
            children: const [
              Expanded(child: _CourseTab(title: 'Completed', selected: false)),
              SizedBox(width: 12),
              Expanded(child: _CourseTab(title: 'Ongoing', selected: true)),
            ],
          ),

          const SizedBox(height: 20),

          // Course cards
          CourseCard(
            category: 'UI/UX Design',
            title: 'Intro to UI/UX Design',
            rating: '4.4',
            duration: '3 Hrs 06 Mins',
            progress: 0.75,
            progressText: '93/125',
            progressColor: const Color(0xFF167F71),
          ),

          CourseCard(
            category: 'Web Development',
            title: 'Wordpress website Dev..',
            rating: '3.9',
            duration: '1 Hrs 58 Mins',
            progress: 0.4,
            progressText: '12/31',
            progressColor: const Color(0xFFFCCB40),
          ),

          CourseCard(
            category: 'UI/UX Design',
            title: '3D Blender and UI/UX',
            rating: '4.6',
            duration: '2 Hrs 46 Mins',
            progress: 0.6,
            progressText: '56/98',
            progressColor: const Color(0xFFFF6B00),
          ),

          CourseCard(
            category: 'UX/UI Design',
            title: 'Learn UX User Persona',
            rating: '3.9',
            duration: '1 Hrs 58 Mins',
            progress: 0.83,
            progressText: '29/35',
            progressColor: const Color(0xFFFCCB40),
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
                    const SizedBox(width: 6),
                    Text(
                      rating,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 12),
                    const Text('|', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 12),
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
            const SizedBox(height: 8),
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
        border: selected ? null : Border.all(color: Colors.transparent),
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
