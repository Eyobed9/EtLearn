import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  bool isRequestsTab = true;

  List<Map<String, dynamic>> requests = [];
  final supabase = Supabase.instance.client;
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  /// Load pending requests for courses the teacher owns
  Future<void> _loadRequests() async {
    List<Map<String, dynamic>> loadedRequests = [];

    try {
      final response = await supabase
          .from('offers')
          .select('''
            id,
            uid,
            subject,
            description,
            available_times,
            status,
            users ( full_name, photo_url )
          ''')
          .eq('type', 'learn')
          .eq('status', 'open');

      // Only requests where the subject matches one of teacher's subjects
      final teacherData = await supabase
          .from('users')
          .select('subjects_teach')
          .eq('uid', uid)
          .maybeSingle();

      final List<String> subjectsTeach =
          List<String>.from(teacherData?['subjects_teach'] ?? []);

      final filteredRequests = (response as List)
          .where((r) => subjectsTeach.contains(r['subject']))
          .toList();

      loadedRequests.addAll(filteredRequests.cast<Map<String, dynamic>>());
    } catch (e) {
      debugPrint('Error fetching requests: $e');
    }

    // Add one demo request for testing if empty
    if (loadedRequests.isEmpty) {
      loadedRequests.add({
        'id': 0,
        'uid': 'demo',
        'subject': 'Demo Subject',
        'description': 'This is a demo request for testing',
        'available_times': ['Anytime'],
        'status': 'open',
        'users': {'full_name': 'Demo Student', 'photo_url': null},
      });
    }

    setState(() {
      requests = loadedRequests;
    });
  }

  /// Accept a request
  Future<void> _acceptRequest(int offerId) async {
    if (offerId == 0) {
      // Demo request: just remove from UI
      setState(() => requests.removeWhere((r) => r['id'] == 0));
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demo request accepted!')));
      return;
    }

    try {
      await supabase
          .from('offers')
          .update({'status': 'accepted'})
          .eq('id', offerId);

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Request accepted!')));

      _loadRequests();
    } catch (e) {
      debugPrint('Error accepting request: $e');
    }
  }

  /// Decline a request
  Future<void> _declineRequest(int offerId) async {
    if (offerId == 0) {
      setState(() => requests.removeWhere((r) => r['id'] == 0));
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demo request declined!')));
      return;
    }

    try {
      await supabase
          .from('offers')
          .update({'status': 'declined'})
          .eq('id', offerId);

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Request declined!')));

      _loadRequests();
    } catch (e) {
      debugPrint('Error declining request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Inbox',
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
            // Tabs
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isRequestsTab = false),
                    child: _TabButton(title: 'Chat', selected: !isRequestsTab),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isRequestsTab = true),
                    child: _TabButton(title: 'Requests', selected: isRequestsTab),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Content
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
                child: isRequestsTab
                    ? requests.isEmpty
                        ? const Center(
                            child: Text(
                              'No pending requests',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: requests.length,
                            itemBuilder: (context, index) {
                              final req = requests[index];
                              final user = req['users'];
                              return RequestTile(
                                requesterName: user?['full_name'] ?? 'Unknown',
                                subject: req['subject'],
                                description: req['description'] ?? '',
                                onAccept: () => _acceptRequest(req['id']),
                                onDeny: () => _declineRequest(req['id']),
                              );
                            },
                          )
                    : const Center(
                        child: Text(
                          'Chat screen here...',
                          style: TextStyle(color: Colors.grey),
                        ),
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
  final String requesterName;
  final String subject;
  final String description;
  final VoidCallback onAccept;
  final VoidCallback onDeny;

  const RequestTile({
    super.key,
    required this.requesterName,
    required this.subject,
    required this.description,
    required this.onAccept,
    required this.onDeny,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            requesterName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF202244),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$subject • $description',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF545454),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF167F71),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Accept'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onDeny,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF44336),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Decline'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
