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

  const MentorTile({
    super.key,
    required this.name,
    this.subtitle = '3D Design',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontFamily: 'Jost',
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF202244),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF545454),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
