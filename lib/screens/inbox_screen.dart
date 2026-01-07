import 'package:flutter/material.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Indox',
          style: TextStyle(
            color: Color(0xFF202244),
            fontFamily: 'Jost',
            fontSize: 21,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 16),

            /// Tabs
            Row(
              children: const [
                Expanded(child: _TabButton(title: 'Chat', selected: false)),
                SizedBox(width: 12),
                Expanded(child: _TabButton(title: 'Requests', selected: true)),
              ],
            ),

            const SizedBox(height: 16),

            /// White card
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
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

                /// List
                child: ListView(
                  children: const [
                    RequestTile(
                      name: 'Johan',
                      date: 'Nov 03, 202X',
                      type: 'Incoming',
                    ),
                    RequestTile(
                      name: 'Timothee Mathew',
                      date: 'Nov 05, 202X',
                      type: 'Incoming',
                    ),
                    RequestTile(
                      name: 'Amanriya',
                      date: 'Nov 06, 202X',
                      type: 'Outgoing',
                    ),
                    RequestTile(
                      name: 'Tanisha',
                      date: 'Nov 15, 202X',
                      type: 'Missed',
                    ),
                    RequestTile(
                      name: 'Shravya',
                      date: 'Nov 17, 202X',
                      type: 'Outgoing',
                    ),
                    RequestTile(
                      name: 'Tamanha',
                      date: 'Nov 18, 202X',
                      type: 'Missed',
                    ),
                    RequestTile(
                      name: 'Hilda M. Hernandez',
                      date: 'Nov 19, 202X',
                      type: 'Outgoing',
                    ),
                    RequestTile(
                      name: 'Wanda T. Seidl',
                      date: 'Nov 21, 202X',
                      type: 'Incoming',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String title;
  final bool selected;

  const _TabButton({required this.title, required this.selected});

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
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class RequestTile extends StatelessWidget {
  final String name;
  final String date;
  final String type;

  const RequestTile({
    super.key,
    required this.name,
    required this.date,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          /// Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE8F1FF), width: 2),
            ),
          ),

          const SizedBox(width: 16),

          /// Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Color(0xFF202244),
                    fontFamily: 'Jost',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$type | $date\nRequested peer training',
                  style: const TextStyle(
                    color: Color(0xFF545454),
                    fontFamily: 'Mulish',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
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
