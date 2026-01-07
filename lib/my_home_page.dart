import 'package:flutter/material.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FE),
      bottomNavigationBar: _bottomNav(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _header(),
            _pad(_searchBar(), top: 20),
            _pad(_sectionTitle("Categories"), top: 30),
            _pad(_categories(), top: 10),
            _pad(_sectionTitle("Popular Courses"), top: 30),
            _pad(_filters(), top: 10),
            _pad(
              _courseCard(
                title: "Graphic Design Advanced",
                price: "850/-",
                students: "7830 Std",
              ),
              top: 20,
            ),
            _pad(
              _courseCard(
                title: "Advertisement Designing",
                price: "400/-",
                students: "12580 Std",
              ),
              top: 20,
            ),
            _pad(_sectionTitle("Top Mentor"), top: 30),
            _pad(_mentors(), top: 15),
          ],
        ),
      ),
    );
  }

  // ================= Helpers =================

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
            children: const [
              Text(
                "Hi, ALEX",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF202244),
                ),
              ),
              Padding(
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
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
                color: Color(0xFF0961F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.search, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
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
          const Text(
            "SEE ALL",
            style: TextStyle(
              color: Color(0xFF0961F5),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _categories() {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text("3D Design", style: TextStyle(color: Color(0xFFA0A4AB))),
          Text("Arts & Humanities", style: TextStyle(color: Color(0xFF0961F5))),
          Text("Graphic Design", style: TextStyle(color: Color(0xFFA0A4AB))),
        ],
      ),
    );
  }

  Widget _filters() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 10,
        runSpacing: 8,
        children: [
          _chip("All", false),
          _chip("Graphic Design", true),
          _chip("3D Design", false),
          _chip("Arts & Humanities", false),
        ],
      ),
    );
  }

  Widget _chip(String text, bool active) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Chip(
        backgroundColor: active
            ? const Color(0xFF167F71)
            : const Color(0xFFE8F1FF),
        label: Text(
          text,
          style: TextStyle(
            color: active ? Colors.white : const Color(0xFF202244),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _courseCard({
    required String title,
    required String price,
    required String students,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 130,
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Graphic Design",
                    style: TextStyle(
                      color: Color(0xFFFF6B00),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      "$price  |  4.2  |  $students",
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0961F5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mentors() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          _Mentor(name: "Jiya"),
          _Mentor(name: "Aman"),
          _Mentor(name: "Rahul.J"),
          _Mentor(name: "Manav"),
        ],
      ),
    );
  }

  static Widget _bottomNav() {
    return BottomNavigationBar(
      selectedItemColor: const Color(0xFF167F71),
      unselectedItemColor: const Color(0xFF202244),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.book), label: "My Courses"),
        BottomNavigationBarItem(icon: Icon(Icons.inbox), label: "Inbox"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    );
  }
}

// ================= Mentor Widget =================

class _Mentor extends StatelessWidget {
  final String name;
  const _Mentor({required this.name});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 70,
          width: 70,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF202244),
            ),
          ),
        ),
      ],
    );
  }
}
