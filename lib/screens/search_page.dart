import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();

  final List<String> recentSearches = const [
    '3D Design',
    'Graphic Design',
    'Programming',
    'SEO & Marketing',
    'Web Development',
    'Office Productivity',
    'Personal Development',
    'Finance & Accounting',
    'HR Management',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FE),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // Top Bar with back button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF202244),
                    ),
                  ),
                  // keep status icons visually similar
                  Row(
                    children: [
                      Container(
                        width: 22,
                        height: 11,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 18,
                        height: 7,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(1.3),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Title
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Search',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Jost',
                    color: const Color(0xFF202244),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Search Box (TextField)
              Container(
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
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Search for...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 18,
                          ),
                        ),
                        style: const TextStyle(
                          color: Color(0xFF202244),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // perform quick search action or focus
                        // for now just unfocus to dismiss keyboard
                        FocusScope.of(context).unfocus();
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0961F5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.search, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Recents Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Recents Search',
                    style: TextStyle(
                      color: Color(0xFF202244),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Jost',
                    ),
                  ),
                  Text(
                    'SEE ALL',
                    style: TextStyle(
                      color: Color(0xFF0961F5),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Mulish',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // Recent Search Items
              Expanded(
                child: ListView.separated(
                  itemCount: recentSearches.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 15),
                  itemBuilder: (context, index) {
                    return RecentSearchItem(text: recentSearches[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecentSearchItem extends StatelessWidget {
  final String text;

  const RecentSearchItem({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFFA0A4AB),
              fontSize: 15,
              fontWeight: FontWeight.w700,
              fontFamily: 'Mulish',
            ),
          ),
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF472D2D),
              borderRadius: BorderRadius.circular(5),
            ),
            child: const Text(
              'X',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
