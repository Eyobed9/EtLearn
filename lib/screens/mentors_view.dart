import 'package:flutter/material.dart';
import 'package:et_learn/widgets/mentor_widgets.dart';

class MentorsView extends StatelessWidget {
  const MentorsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FE),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Mentors',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(),
            ),

            _searchBox(),

            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Container(),
            ),

            Row(
              children: [
                const Expanded(
                  child: TabButton(title: 'Courses', selected: false),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: SizedBox(),
                ),
                const Expanded(
                  child: TabButton(title: 'Mentors', selected: true),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Result for “',
                        style: TextStyle(
                          fontFamily: 'Jost',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: '3D Design',
                        style: TextStyle(
                          color: Color(0xFF0961F5),
                          fontFamily: 'Jost',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: '”',
                        style: TextStyle(
                          fontFamily: 'Jost',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '18 FOUND',
                  style: TextStyle(
                    color: Color(0xFF0961F5),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(),
            ),

            Expanded(
              child: ListView(
                children: const [
                  MentorTile(name: 'Ramal'),
                  MentorTile(name: 'Aman MK'),
                  MentorTile(name: 'Manav M'),
                  MentorTile(name: 'Siya Dhawal'),
                  MentorTile(name: 'Robert Jr'),
                  MentorTile(name: 'William K. Olivas'),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: const Color(0xFF167F71),
        unselectedItemColor: const Color(0xFF202244),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'HOME'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'MY COURSES'),
          BottomNavigationBarItem(icon: Icon(Icons.inbox), label: 'INBOX'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'PROFILE'),
        ],
      ),
    );
  }

  Widget _searchBox() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
              '3D Design',
              style: TextStyle(
                color: Color(0xFFB4BDC4),
                fontFamily: 'Mulish',
                fontSize: 16,
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
