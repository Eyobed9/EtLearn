import 'package:flutter/material.dart';

class TabButton extends StatelessWidget {
  final String title;
  final bool selected;

  const TabButton({super.key, required this.title, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF167F71) : const Color(0xFFE8F1FF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: selected ? Colors.white : const Color(0xFF202244),
          fontFamily: 'Mulish',
          fontWeight: FontWeight.w800,
          fontSize: 15,
        ),
      ),
    );
  }
}

class MentorTile extends StatelessWidget {
  final String name;
  final String subtitle;
  final String? photoUrl;

  const MentorTile({
    super.key,
    required this.name,
    this.subtitle = '3D Design',
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          // Profile image
          CircleAvatar(
            radius: 33,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
                ? NetworkImage(photoUrl!)
                : null,
            child: photoUrl == null || photoUrl!.isEmpty
                ? const Icon(Icons.person, size: 33)
                : null,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 70,
            child: Text(
              name,
              style: const TextStyle(
                fontFamily: 'Jost',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF202244),
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'Mulish',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF545454),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
