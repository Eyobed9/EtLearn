import 'dart:async';
import 'package:flutter/material.dart';
import 'package:et_learn/models/request_data.dart';
import 'package:et_learn/helpers/credits.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jitsi_meet_wrapper/jitsi_meet_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  bool isRequestsTab = true;

  List<RequestData> requests = [];
  final supabase = Supabase.instance.client;
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _loadCredits();
    _loadRequests();
  }

  /// Load user's current credits
  Future<void> _loadCredits() async {
    try {
      final data = await supabase
          .from('users')
          .select('credits')
          .eq('uid', uid)
          .maybeSingle();

      if (data is Map<String, dynamic>) {
        totalCreditsNotifier.value = data['credits'] ?? 0;
      }
    } catch (e) {
      debugPrint('Error loading credits: $e');
    }
  }

  /// Load pending requests (or demo request)
  Future<void> _loadRequests() async {
    // For demo purposes, always include a demo request
    final List<RequestData> loadedRequests = [
      const RequestData(
        id: 'demo1',
        name: 'Demo Student',
        course: 'Flutter Basics',
        duration: '1 Hr',
        coins: 50,
        availableTimes: ['Now +5 sec'],
      ),
    ];

    setState(() {
      requests = loadedRequests;
    });
  }

  /// Add coins to existing credits in Supabase
  Future<void> _addCoins(int coinsToAdd) async {
    try {
      // Fetch current credits
      final data = await supabase
          .from('users')
          .select('credits')
          .eq('uid', uid)
          .maybeSingle();

      int currentCredits = totalCreditsNotifier.value;
      if (data is Map<String, dynamic>) {
        currentCredits = data['credits'] ?? currentCredits;
      }

      // Add coins
      final newCredits = currentCredits + coinsToAdd;

      // Update Supabase
      await supabase
          .from('users')
          .update({'credits': newCredits})
          .eq('uid', uid);

      // Update notifier
      totalCreditsNotifier.value = newCredits;
    } catch (e) {
      debugPrint('Error adding coins: $e');
    }
  }

  /// Start Jitsi meeting and credit coins afterwards
  Future<void> _startDemoMeeting(RequestData request) async {
    // Remove request from UI immediately
    setState(() {
      requests.remove(request);
    });

    final roomName =
        'ETLearn_${request.name}_${DateTime.now().millisecondsSinceEpoch}';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Meeting with ${request.name} will start in 5 seconds...',
        ),
      ),
    );

    // Simulate short countdown
    await Future.delayed(const Duration(seconds: 5));

    // Start Jitsi meeting
    await JitsiMeetWrapper.joinMeeting(
      options: JitsiMeetingOptions(
        roomNameOrUrl: roomName,
        userDisplayName: 'Teacher',
      ),
    );

    // Add coins after meeting ends
    await _addCoins(request.coins);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Meeting with ${request.name} ended. Coins (${request.coins}) credited!',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ValueListenableBuilder<int>(
          valueListenable: totalCreditsNotifier,
          builder: (context, totalCredits, _) {
            return Text(
              'Inbox',
              style: const TextStyle(
                color: Color(0xFF202244),
                fontFamily: 'Jost',
                fontSize: 21,
                fontWeight: FontWeight.w600,
              ),
            );
          },
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
                    child: _TabButton(
                      title: 'Requests',
                      selected: isRequestsTab,
                    ),
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
                          : ListView(
                              children: requests
                                  .map(
                                    (req) => RequestTile(
                                      request: req,
                                      onAccept: () => _startDemoMeeting(req),
                                      onDeny: () {
                                        setState(() {
                                          requests.remove(req);
                                        });
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Denied ${req.name}, requester notified.',
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                  .toList(),
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

/// Tab button used in the inbox header.
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

/// Shows a single request with Accept/Deny buttons.
class RequestTile extends StatelessWidget {
  final RequestData request;
  final VoidCallback onAccept;
  final VoidCallback onDeny;

  const RequestTile({
    super.key,
    required this.request,
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
            request.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF202244),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${request.course} • ${request.duration} • ${request.coins} coins',
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
                  child: const Text('Deny'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
